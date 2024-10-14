#!/usr/bin/env zx

const BackupsBase = '/Main/Backup';
const TimeLimit = { years: 0, months: 1, days: 0 };

const maxDate = (new Date());
maxDate.setDate(maxDate.getDate() - TimeLimit.days);
maxDate.setMonth(maxDate.getMonth() - TimeLimit.months);
maxDate.setYear(maxDate.getFullYear() - TimeLimit.years);

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
		if (fileDate > maxDate) {
			continue;
		}
		await $`rm ${file}`;
	}
}
