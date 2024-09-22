#!/usr/bin/env zx

const BackupsBase = '/Main/Backup';
const TimeLimit = [0, 1, 0];

let [year, month, day] = TimeLimit;
const maxDate = { year, month, day };

const nowDate = (new Date());
//const nowDate = {
//	year: Number(Time.getFullYear()),
//	month: Number((Time.getMonth() + 1).toString().padStart(2, '0')),
//	day: Number(Time.getDate().toString().padStart(2, '0')),
//};

cd(BackupsBase);
const allDirsList = String(await $`ls -d */`).trim().split('\n');
const gitDirsList = String(await $`ls -d */.git`).trim().split('\n');
for (const folder of allDirsList) {
	if (gitDirsList.includes(`${folder}.git`)) {
		continue;
	}
	const filesList = [
		...String(await $`ls ${folder}????-??-??.* || true`).trim().split('\n'),
		...String(await $`ls ${folder}*.????-??-??.* || true`).trim().split('\n'),
	];
	for (const file of filesList) {
		if (file.includes('?')) {
			continue;
		}
		let [year, month, day] = file.split('/')[1].split('-');
		year = year.split('.').slice(-1)[0];
		month = month;
		day = day.split('.')[0];
		const fileDate = (new Date(`${year}-${month}-${day}`));
		
		//$`rm`
	}
}
