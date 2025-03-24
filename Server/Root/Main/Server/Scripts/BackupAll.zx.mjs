#!/usr/bin/env zx

const BackupsBase = '/Main/Backup';
const GenericBrowserUserAgent = 'Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0';
const Time = new Date();

Time.Stamp = `${Time.getFullYear()}-${(Time.getMonth() + 1).toString().padStart(2, '0')}-${Time.getDate().toString().padStart(2, '0')}`;
cd(BackupsBase);

const [Jobs, Secrets] = [{}, {}];

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

const EnsureFolder = async (path) => {
	await $`mkdir -vp ${path}`;
	cd(path);
}

//const ExecAs = async (cmdline, user) => {
//	//return await $`${user ? ('sudo -u ' + user) : ''} sh -c '${cmdline}'`;
//};

//const GitPullPush = async (user) => await ExecAs(`git pull; git add . && git commit -m "Auto-Backup ${Time}" && git push || true`, user);
const GitReclone = async (path, url, branch) => await $`rm -rf ${path}.old || true; mv ${path} ${path}.old; git clone --depth 1 --single-branch ${url} ${branch ? `--branch ${branch}` : ''}`;
const GitPullPush = async () => await $`git pull; git add .; git commit -m "Auto-Backup ${Time}" || true; git push || true`;

const BackPathCrypt = async (Folder, Key, Ext) => {
	Ext ||= '.tar.xz';
	const File = `${Folder}${Ext}`;
	await $`cp "../${Folder}/Latest${Ext}" "./${File}"`;
	await ccencryptNow(`./${File}`, Key);
};

const SimpleCompress = async (dst, src) => await $`rm -f ${dst}.tar.xz || true; tar cJSf "${dst}.tar.xz" ${src || dst}`;

const SimpleBackup = async (Folder, Prefix) => {
	await $`mkdir -vp ./${Folder}`;
	await $`rm -f ./${Folder}/Latest.tar.xz || true`;
	await $`rm -rf ./${Folder}/Latest.d || true`;
	await $`cp -rp /Main/Server/${Prefix || ''}/${Folder} ./${Folder}/Latest.d`;
	await SimpleCompress(`./${Folder}/${Time.Stamp}`, `./${Folder}/Latest.d`);
	await $`ln -s ./${Time.Stamp}.tar.xz ./${Folder}/Latest.tar.xz`;
};

const CompressAndUpdate = async (folder, name, extension) => {
	await SimpleCompress(
		`./${folder}/${name}.${Time.Stamp}.${extension}`,
		`./${folder}/${name}.Latest.${extension}`,
	);
	await $`rm -f ./${folder}/${name}.Latest.${extension}.tar.xz || true`;
	await $`ln -s ./${name}.${Time.Stamp}.${extension}.tar.xz ./${folder}/${name}.Latest.${extension}.tar.xz`;
};

const AltervistaFullBackup = async (domain) => {
	const [user, pass, key] = Secrets[`${domain.replaceAll('.', '_')}_Backup_Tokens`].split(':');
	cd(`./${domain}-Git`);
	await $`rclone sync ${domain}:/ ./www/wp-content/ --progress || true`;
	await $`rm -f ./www/wp-content/uploads/iawp-geo-db.mmdb || true`; // file > 100MB, can't be pushed
	await $`curl -u ${user}:${pass} https://${domain}/wp-json/octt-export-rest/v1/xrss-export?token=${key} > ./WordPress.xml || true`;
	await GitPullPush();
};

const LampBackup = async (folder, table) => {
	await SimpleBackup(folder, 'www');
	await $`lxc-attach Debian2023 -- mariadb-dump ${table || folder} > ./${folder}/Db.Latest.sql`;
	await CompressAndUpdate(folder, 'Db', 'sql');
};

const FolderGoCopyForCloud = async (src, dst) => {
	if (dst) {
		cd(`./${dst}`);
	}
	await $`rm -rf ./${src} || true`;
	await $`cp -rp ../${src}/Latest.d ./${src}`;
	await $`rm -rf ./${src}/.git || true`;
};

const ScriptAndGitBackup = async (folder, command, program='sh') => {
	cd(folder);
	await $`${program} ${command}`;
	await GitPullPush();
};

const Work = async (jobName) => {
	const filterText = process.argv.slice(-1)[0];
	const isFilter = filterText.endsWith('_');
	if (!isFilter || (isFilter && jobName.startsWith(filterText))) {
		return await within(Jobs[jobName]);
	}
}

////////////////////////////////////////////////////////////////////////////////

Jobs.Local_MiscSimpleBackups = async () => {
	async function Local_Memos () {
		await $`sudo docker stop memos`;
		await SimpleBackup('memos');
		await $`sudo docker start memos`;
	}
	await SimpleBackup('FreshRSS', 'www');
	await SimpleBackup('n8n-data');
	await SimpleBackup('script-server');
	await SimpleBackup('docker-mailserver');
	await Local_Memos();
};

Jobs.Local_Shiori = async () => {
	await SimpleBackup('shiori-data', 'Shiori');
	await $`rm -vf ./shiori-data/Latest.d/archive/* || true`;
};

Jobs.Local_SpaccBBS = () => LampBackup('SpaccBBS', 'phpBB');

Jobs.Local_SpaccBBSNodeBB = async () => {
	await SimpleBackup('SpaccBBS-NodeBB');
	await $`lxc-attach Debian2023 -- redis-cli -n 2 --rdb - > ./SpaccBBS-NodeBB/Db.Latest.rdb`;
	await CompressAndUpdate('SpaccBBS-NodeBB', 'Db', 'rdb');
};

Jobs.Local_liminalgici = () => LampBackup('pixelfed_liminalgici');

Jobs.Local_Doku = () => SimpleBackup('dokuwiki', 'www');

Jobs.Cloud_Doku = async () => {
	await FolderGoCopyForCloud('dokuwiki', 'doku.spacc.eu.org-Git');
	await $`rm -rf ./dokuwiki/data/cache || true`;
	await GitPullPush();
};

// NOTE: embedded media is not handled (neither included nor downloaded)
Jobs.archivioctt_Memos = async () => {
	EnsureFolder('./archivioctt-Git/docs/memos');
	await $`rm -f * || true`;
	await stream.Readable.fromWeb((await fetch('https://memos.octt.eu.org/memos.api.v1.MemoService/ExportMemos', {
		headers: {
			"content-type": "application/grpc-web+proto",
			"cookie": Secrets.Memos_Backup_Cookie,
		},
		body: "\u0000\u0000\u0000\u0000\u0016\n\u0014creator == \"users/1\"",
		method: "POST",
	})).body).pipe(fs.createWriteStream('./Memos.zip'));
	await $`unzip -o ./Memos.zip || true`; // zip has 9 extra bytes at the start, unzip handles it fine with a warning
	await $`rm -f ./Memos.zip || true`;
	await $`sh ../../scripts/memos-to-mkdocs.sh`;
	await GitPullPush();
};

// NOTE: post tags, post location, and media license are not handled; media is not redownloaded
Jobs.archivioctt_Pixelfed = async () => {
	EnsureFolder('./archivioctt-Git/docs/pictures/posts');
	const allPosts = [];
	for (const identity of ["liminalgici.spacc.eu.org:664033260845064193"]) {
		let offset = '';
		const [instance, account] = identity.split(':');
		while (true) {
			const posts = (await (await fetch(`https://${instance}/api/pixelfed/v1/accounts/${account}/statuses?only_media=true&max_id=${offset}`)).json());
			if (posts.length > 0) {
				offset = posts.slice(-1)[0].id;
				allPosts.push(...posts);
			} else {
				break;
			}
		}
	}
	for (const post of allPosts) {
		fs.writeFileSync(`${post.id}.md`, `---
canonical_url: ${post.url}
date: ${post.created_at}
tags: ${post.tags.map(tag => `\n  - ${tag.name}`).join('')}
---
\n${post.content.replaceAll('<br />', '')}
\n${post.media_attachments.map(media => `![${media.description}](${media.url})`).join('\n\n')}`);
	}
};

Jobs.Mixed_OctospaccAltervista = async () => {
	await AltervistaFullBackup('octospacc.altervista.org');
	cd('../microblog-mirror');
		await $`rm -rf ./_posts ./assets/uploads/* || true`;
	cd('../archivioctt-Git');
		await $`rm -rf ./docs/microblog/posts || true`;
	cd('../octospacc.altervista.org-Git');
		for (const folder of ["microblog-mirror/_posts", "archivioctt-Git/docs/microblog/posts"]) {
			await $`cp -r ./www/wp-content/octt-export-markdown/${Secrets.octospacc_altervista_org_MarkdownKey}/_posts ../${folder}`;
		}
		cd('./www/wp-content/uploads');
			await $`cp -r $(seq 2020 $(date +%Y)) ../../../../microblog-mirror/assets/uploads/ || true`;
	cd('../../../');
	cd('../microblog-mirror');
		await $`sh ./filter-fix-posts.sh`;
		await GitPullPush();
	cd('../archivioctt-Git');
		await $`sh ./scripts/microblog-to-mkdocs.sh`;
		await GitPullPush();
};

Jobs.Mixed_Configs = () => ScriptAndGitBackup('./Configs', './Server/Repo.Update.sh');
Jobs.Mixed_Snippets = () => ScriptAndGitBackup('./Snippets', './.CopyFromServer.sh');

// TODO: setup FTP access and Cookie
Jobs.Mixed_SpacccraftAltervista = async () => {
	await AltervistaFullBackup('spacccraft.altervista.org', Secrets.SpacccraftAltervista_Backup_Cookie);
};

// TODO: everything
Jobs.Exter_WikiSpacc = async () => {
	// ...
};

Jobs.Cloud_ServerBackupLimited = async () => {
	await GitReclone('Server-Backup-Limited', 'https://gitlab.com/octospacc/Server-Backup-Limited/');
	cd('./Server-Backup-Limited');
	await BackPathCrypt('FreshRSS', Secrets.BackupKey_Git_FreshRSS);
	await BackPathCrypt('n8n-data', Secrets.BackupKey_Git_n8n);
	await BackPathCrypt('script-server', Secrets.BackupKey_Git_scriptserver);
	await BackPathCrypt('docker-mailserver', Secrets.BackupKey_Git_dockermailserver);
	await BackPathCrypt('memos', Secrets.BackupKey_Git_memos);
	await $`split --bytes=95M --numeric-suffixes ./FreshRSS.tar.xz.cpt FreshRSS.tar.xz.cpt.`;
	await $`rm ./FreshRSS.tar.xz.cpt`;
	await GitPullPush();
};

Jobs.Cloud_ArticlesBackupPrivate = async () => {
	await GitReclone('Articles-Backup-Private', 'https://gitlab.com/octospacc/Articles-Backup-Private/');
	await FolderGoCopyForCloud('shiori-data', 'Articles-Backup-Private');
	await GitPullPush();
};

Jobs.Cloud_SpaccBBS = async () => {
	await FolderGoCopyForCloud('SpaccBBS', 'SpaccBBS-Backup-phpBB-2023');
	await $`cp ../SpaccBBS/Db.Latest.sql.tar.xz ./Db.sql.tar.xz`;
	for (const File of ['Db.sql.tar.xz', 'SpaccBBS/old/config.php', 'SpaccBBS/old/arrowchat/includes/config.php']) {
		await ccencryptNow(`./${File}`, Secrets.BackupKey_Git_SpaccBBS);
	};
	await GitPullPush();
};

Jobs.Cloud_SpaccBBSNodeBB = async () => {
	await FolderGoCopyForCloud('SpaccBBS-NodeBB', 'SpaccBBS-NodeBB-2024-Git');
	await $`rm -rf ./SpaccBBS-NodeBB/.git || true`;
	await $`cp ../SpaccBBS-NodeBB/Db.Latest.rdb.tar.xz ./Db.rdb.tar.xz`;
	await ccencryptNow('./Db.rdb.tar.xz', Secrets.BackupKey_Git_SpaccBBSNodeBB);
	await GitPullPush();
};

Jobs.Cloud_liminalgici = async () => {
	await FolderGoCopyForCloud('pixelfed_liminalgici', 'liminalgici.spacc.eu.org-Git');
	await $`cp ../pixelfed_liminalgici/Db.Latest.sql.tar.xz ./Db.sql.tar.xz`;
	await SimpleCompress('./pixelfed_liminalgici/config');
	await $`rm -rf ./pixelfed_liminalgici/config || true`;
	for (const File of ['Db.sql.tar.xz', './pixelfed_liminalgici/.env', './pixelfed_liminalgici/config.tar.xz']) {
		await ccencryptNow(`./${File}`, Secrets.BackupKey_Git_liminalgici);
	};
	//await $`rm ./pixelfed_liminalgici/storage/app/public/m/.gitignore || true`;
	await GitPullPush();
};

Jobs.Cloud_SpaccCraft = async () => {
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

Jobs.Cloud_Private = () => $`sudo -u tux rclone sync /Main/Clouds/octt GDrive-Uni-Crypt:/Clouds.octt --progress`;

////////////////////////////////////////////////////////////////////////////////

const Main = async () => {
	await Work('Local_MiscSimpleBackups');
	await Work('Local_Shiori');
	await Work('Local_SpaccBBS');
	await Work('Local_SpaccBBSNodeBB');
	await Work('Local_liminalgici');
	await Work('Local_Doku');

	await Work('Mixed_Configs');
	await Work('Mixed_Snippets');
	await Work('Mixed_OctospaccAltervista');
	//await Work('Mixed_SpacccraftAltervista');
	//await Work('Exter_WikiSpacc');

	await Work('Cloud_ServerBackupLimited');
	await Work('Cloud_ArticlesBackupPrivate');
	await Work('Cloud_SpaccBBS');
	await Work('Cloud_SpaccBBSNodeBB');
	await Work('Cloud_liminalgici');
	await Work('Cloud_Doku');
	await Work('Cloud_SpaccCraft');
	await Work('Cloud_Private');

	//await Work('archivioctt_Memos');
	//await Work('archivioctt_Pixelfed');
	//await Work('archivioctt_WordPress');
	// POST https://public-api.wordpress.com/rest/v1.1/sites/SITEID/exports/start
	// GET https://public-api.wordpress.com/rest/v1.1/sites/SITEID/exports/0?
	// ... {status:"running"} ... {status:"finished","attachment_url":"...zip"}
};

////////////////////////////////////////////////////////////////////////////////

$`echo Begin ${Time.Stamp} > ${BackupsBase}/Last.log`;

await Main();

$`echo End ${Time.Stamp} > ${BackupsBase}/Last.log`;
