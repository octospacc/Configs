#!/usr/bin/env zx

let BackupsBase = '/Main/Backup';
let Time = new Date();

// Note: not padding the year to 5 digits will break the scripts in ~8 millenia. The line should be fixed.
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

const Hash2 = async (BaseKey, Salt) => await $`echo "$(echo "${BaseKey}$(echo ${Salt} | sha512sum | base64 -w0)" | sha512sum | base64 -w0)"`.toString();

const ccencryptNow = async (File, BaseKey) => {
	await $`ccrypt -e -f -K"${Hash2(BaseKey, Time.Stamp)}" ${File}`;
	$`echo ${Time.Stamp} > ${File}.info`;
};

const GitPush = async () => $`git add . && git commit -m "Auto-Backup ${Time}" && git push`;

const BackPathCrypt = async (Folder, Key, Ext) => {
	Ext ||= '.tar.xz';
	const File = `${Folder}${Ext}`;
	await $`cp "../${Folder}/Latest${Ext}" "./${File}" && ccencryptNow "./${File}" "${Key}"`;
};

const SimpleCompress = async (Src, Dst) => await $`tar cJSf "${Dst}.tar.xz" ${Src}`;

const SimpleBackup = async (Folder, Prefix) => {
	await $`mkdir -vp "./${Folder}"`;
	// ...
};

const Work = async (Job) => await within(Jobs[Job]);

///////////////////////////////////////

Jobs.Local_Simple_Backup = async()=>{
	SimpleBackup('FreshRSS', 'www');
	SimpleBackup('n8n-data');
	SimpleBackup('script-server');
	SimpleBackup('docker-mailserver');
};

Jobs.Local_Shiori = async()=>{
	SimpleBackup('shiori-data', 'Shiori');
	$`rm -v ./shiori-data/Latest.d/archive/*`;
};

Jobs.Local_SpaccBBS = async()=>{
	
};

Jobs.Cloud_ServerBackupLimited = async()=>{
	cd('./Server-Backup-Limited');
	BackPathCrypt('FreshRSS', Secrets.BackupKey_Git_FreshRSS);
	BackPathCrypt('n8n-data', Secrets.BackupKey_Git_n8n);
	BackPathCrypt('script-server', Secrets.BackupKey_Git_scriptserver);
	BackPathCrypt('docker-mailserver', Secrets.BackupKey_Git_dockermailserver);
	GitPush();
};

Jobs.Cloud_ArticlesBackupPrivate = async()=>{
	cd('./Articles-Backup-Private');
	await $`rm -rf ./shiori-data`;
	await $`cp -rp ../shiori-data/Latest.d ./shiori-data`;
	GitPush();
};

Jobs.Cloud_SpaccBBS = async()=>{
	cd('./SpaccBBS-Backup-phpBB-2023');
};

Jobs.Cloud_SpaccCraft = async()=>{
	
};

///////////////////////////////////////

Work('Local_Simple_Backup');
Work('Local_Shiori');
Work('Local_SpaccBBS');

Work('Cloud_ServerBackupLimited');
Work('Cloud_ArticlesBackupPrivate');
Work('Cloud_SpaccBBS');
Work('Cloud_SpaccCraft');

$`echo ${Time.Stamp} > ${BackupsBase}/Last.log`;
