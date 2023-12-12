#!/usr/bin/env zx

let BackupsBase = '/Main/Backup';
let Time = new Date();

Time.Stamp = `${Time.getFullYear()}-${(Time.getMonth() + 1).toString().padStart(2, '0')}-${Time.getDate().toString().padStart(2, '0')}`;
cd(BackupsBase);

const GenericBrowserUserAgent = 'Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0';

let [Jobs, Secrets] = [{}, {}];

// Import secrets from sh-formatted file
for (let line of (await fs.readFile('./.BackupSecrects.sec', 'utf8')).split('\n')) {
	line = line.split('#')[0].trim();
	const key = line.split('=')[0];
	let val = line.split('=').slice(1).join('=');
	if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
		val = val.slice(1,  -1);
	};
	Secrets[key] = val;
};

////////////////////////////////////////////////////////////////////////////////

const Hash2 = async (BaseKey, Salt) => (await $`echo "${BaseKey}$(echo ${Salt} | sha512sum | base64 -w0)" | sha512sum | base64 -w0`).toString().trim();

const ccencryptNow = async (File, BaseKey) => {
	await $`ccrypt -e -f -K"${await Hash2(BaseKey, Time.Stamp)}" ${File}`;
	$`echo ${Time.Stamp} > ${File}.info`;
};

//const ExecAs = async (cmdline, user) => {
//	//return await $`${user ? ('sudo -u ' + user) : ''} sh -c '${cmdline}'`;
//};

//const GitPullPush = async (user) => await ExecAs(`git pull; git add . && git commit -m "Auto-Backup ${Time}" && git push || true`, user);
const GitPullPush = async () => await $`git pull; git add .; git commit -m "Auto-Backup ${Time}" || true; git push || true`;

const BackPathCrypt = async (Folder, Key, Ext) => {
	Ext ||= '.tar.xz';
	const File = `${Folder}${Ext}`;
	await $`cp "../${Folder}/Latest${Ext}" "./${File}"`;
	await ccencryptNow(`./${File}`, Key);
};

const SimpleCompress = async (Dst, Src) => await $`rm ${Dst}.tar.xz || true; tar cJSf "${Dst}.tar.xz" ${Src}`;

const SimpleBackup = async (Folder, Prefix) => {
	await $`mkdir -vp ./${Folder}`;
	await $`rm ./${Folder}/Latest.tar.xz || true`;
	await $`rm -rf ./${Folder}/Latest.d || true`;
	await $`cp -rp /Main/Server/${Prefix || ''}/${Folder} ./${Folder}/Latest.d`;
	await SimpleCompress(`./${Folder}/${Time.Stamp}`, `./${Folder}/Latest.d`);
	await $`ln -s ./${Time.Stamp}.tar.xz ./${Folder}/Latest.tar.xz`;
};

const Work = async (Job) => await within(Jobs[Job]);

////////////////////////////////////////////////////////////////////////////////

Jobs.Local_MiscSimpleBackups = async()=>{
	await SimpleBackup('FreshRSS', 'www');
	await SimpleBackup('n8n-data');
	await SimpleBackup('script-server');
	await SimpleBackup('docker-mailserver');
};

Jobs.Local_Shiori = async()=>{
	await SimpleBackup('shiori-data', 'Shiori');
	await $`rm -v ./shiori-data/Latest.d/archive/* || true`;
};

Jobs.Local_SpaccBBS = async()=>{
	await SimpleBackup('SpaccBBS', 'www');
	await $`lxc-attach Debian2023 -- mariadb-dump phpBB > ./SpaccBBS/Db.Latest.sql`;
	await SimpleCompress(`./SpaccBBS/Db.${Time.Stamp}.sql`, './SpaccBBS/Db.Latest.sql');
	await $`rm ./SpaccBBS/Db.Latest.sql.tar.xz || true`;
	await $`ln -s "./Db.${Time.Stamp}.sql.tar.xz" ./SpaccBBS/Db.Latest.sql.tar.xz`;
};

Jobs.Mixed_OctospaccAltervista = async()=>{
	const Domain = 'octospacc.altervista.org';
	cd(`./${Domain}-Git`);
	await $`rclone sync ${Domain}:/ ./www/wp-content/ --progress`;
	//await $`curl 'https://${Domain}/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&submit=Scarica+il+file+di+esportazione' -H 'User-Agent: ${GenericBrowserUserAgent}' -H 'Referer: https://${Domain}/wp-admin/export.php' -H 'Connection: keep-alive' -H 'Cookie: ${Secrets.OctospaccAltervista_Backup_Cookie}' > ./WordPress.xml`;
	const args = [
		`https://${Domain}/wp-admin/export.php?download=true&content=all&cat=0&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&attachment_start_date=0&attachment_end_date=0&submit=Scarica+il+file+di+esportazione`,
		'-H', 'Connection: keep-alive',
		'-H', `User-Agent: ${GenericBrowserUserAgent}`,
		'-H', `Referer: https://${Domain}/wp-admin/export.php`,
		'-H', `Cookie: ${Secrets.OctospaccAltervista_Backup_Cookie}`,
	];
	await $`curl ${args} > ./WordPress.xml`;
	await GitPullPush();
};

Jobs.Mixed_SpacccraftAltervista = async()=>{
	// ...
};

Jobs.Exter_WikiSpacc = async()=>{
	// ...
};

Jobs.Cloud_ServerBackupLimited = async()=>{
	cd('./Server-Backup-Limited');
	await BackPathCrypt('FreshRSS', Secrets.BackupKey_Git_FreshRSS);
	await BackPathCrypt('n8n-data', Secrets.BackupKey_Git_n8n);
	await BackPathCrypt('script-server', Secrets.BackupKey_Git_scriptserver);
	await BackPathCrypt('docker-mailserver', Secrets.BackupKey_Git_dockermailserver);
	await GitPullPush();
};

Jobs.Cloud_ArticlesBackupPrivate = async()=>{
	cd('./Articles-Backup-Private');
	await $`rm -rf ./shiori-data || true`;
	await $`cp -rp ../shiori-data/Latest.d ./shiori-data`;
	await GitPullPush();
};

Jobs.Cloud_SpaccBBS = async()=>{
	cd('./SpaccBBS-Backup-phpBB-2023');
	await $`rm -rf ./SpaccBBS || true`;
	await $`cp -rp ../SpaccBBS/Latest.d ./SpaccBBS`;
	await $`cp ../SpaccBBS/Db.Latest.sql.tar.xz ./Db.sql.tar.xz`;
	for (let File of ['Db.sql.tar.xz', 'SpaccBBS/config.php', 'SpaccBBS/arrowchat/includes/config.php']) {
		await ccencryptNow(`./${File}`, Secrets.BackupKey_Git_SpaccBBS);
	};
	await GitPullPush();
};

Jobs.Cloud_SpaccCraft = async()=>{
	const McServer="SpaccCraft";
	const McEdition="Beta-1.7.3";
	const McGit="spacccraft-b1.7.3-backup4";
	const DestPath=`${BackupsBase}/${McGit}`;
	if (fs.existsSync(DestPath)) {
		cd(`${BackupsBase}/${McServer}`);
		await $`rm -rf "${DestPath}/${McEdition}" || true`;
		await $`cp ./*.sh "${DestPath}/" || true`;
		await $`cp -r "./${McEdition}/Latest.d" "${DestPath}/${McEdition}"`;
	};
	cd(DestPath);
	await GitPullPush();
};

Jobs.Cloud_Private = async()=> await $`sudo -u tux rclone sync /Main/Clouds/octt GDrive-Uni-Crypt:/Clouds.octt --progress`;

////////////////////////////////////////////////////////////////////////////////

await Work('Local_MiscSimpleBackups');
await Work('Local_Shiori');
await Work('Local_SpaccBBS');

await Work('Mixed_OctospaccAltervista');
await Work('Mixed_SpacccraftAltervista');
await Work('Exter_WikiSpacc');

await Work('Cloud_ServerBackupLimited');
await Work('Cloud_ArticlesBackupPrivate');
await Work('Cloud_SpaccBBS');
await Work('Cloud_SpaccCraft');
await Work('Cloud_Private');

$`echo ${Time.Stamp} > ${BackupsBase}/Last.log`;
