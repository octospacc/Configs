#!/usr/bin/env zx

let BackupsBase = '/Main/Backup';
let Time = new Date();

Time.Stamp = `${Time.getFullYear()}-${(Time.getMonth() + 1).toString().padStart(2, '0')}-${Time.getDate().toString().padStart(2, '0')}`;
cd(BackupsBase);

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

const GitPullPush = async () => await $`git pull; git add . && git commit -m "Auto-Backup ${Time}" && git push || true`;

const BackPathCrypt = async (Folder, Key, Ext) => {
	Ext ||= '.tar.xz';
	const File = `${Folder}${Ext}`;
	await $`cp "../${Folder}/Latest${Ext}" "./${File}"`;
	await ccencryptNow(`./${File}`, Key);
};

const SimpleCompress = async (Dst, Src) => await $`rm ${Dst}.tar.xz || true; tar cJSf "${Dst}.tar.xz" ${Src}`;

const SimpleBackup = async (Folder, Prefix) => {
	//await $`mkdir -vp "./${Folder}"`;
	//await $`rm "./${Folder}/Latest.tar.xz" || true`;
	//await $`rm -rf "./${Folder}/Latest.d" || true`;
	//await $`cp -rp "/Main/Server/${Prefix}/${Folder}" "./${Folder}/Latest.d"`;
	//await SimpleCompress(`./${Folder}/${Time.Stamp}`, `./${Folder}/Latest.d`);
	//await $`ln -s "./${Time.Stamp}.tar.xz" "./${Folder}/Latest.tar.xz"`;
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

Jobs.Exter = async()=>{
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

Jobs.Cloud_Private = async()=> await $`sudo -u tux rclone sync -v /Main/Clouds/octt GDrive-Uni-Crypt:/`;

////////////////////////////////////////////////////////////////////////////////

await Work('Local_MiscSimpleBackups');
await Work('Local_Shiori');
await Work('Local_SpaccBBS');
await Work('Exter');

await Work('Cloud_ServerBackupLimited');
await Work('Cloud_ArticlesBackupPrivate');
await Work('Cloud_SpaccBBS');
await Work('Cloud_SpaccCraft');
//await Work('Cloud_Private');

$`echo ${Time.Stamp} > ${BackupsBase}/Last.log`;
