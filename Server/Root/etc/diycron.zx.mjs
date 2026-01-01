#!/usr/bin/env zx
let Jobs = {};

const ResetJobs = () => (Jobs = {
	Backup: false,
	Certs: false,
});
ResetJobs();

const Work = (Job, Funct) => {
	if (!Jobs[Job]) {
		Jobs[Job] = true;
		Funct();
	};
};

echo`=====[ diycron started at ${new Date()} ]=====`;

while (true) {

const T = new Date();
//T.Y = T.getFullYear()
T.M = (T.getMonth() +1);
T.D = T.getDate();
T.h = T.getHours();
T.m = T.getMinutes();
//T.s = T.getSeconds();
T.is = (question) => {
	let allTrue = true;
	for (let predicate in question) {
		let word = predicate.replaceAll('_', '');
		let oracle = {
			//Y: T.Y,
			M: T.M,
			D: T.D,
			h: T.h,
			m: T.m,
			//s: T.s,
		}[word];
		if (predicate.endsWith('_') && predicate.startsWith('_')) {
			!((oracle % question[predicate]) == 0) && (allTrue = false);
		} else if (predicate.endsWith('_')) {   // w_
			!(oracle <= question[predicate]) && (allTrue = false);
		} else if (predicate.startsWith('_')) { // _w
			!(oracle >= question[predicate]) && (allTrue = false);
		} else {
			!(oracle == question[predicate]) && (allTrue = false);
		};
	};
	return allTrue;
};

///////////////////////////////////////


//T.is({ /*_D_:'2',*/ h:'03', m_:'10' }) && (T.D % 2 === 0)
//T.is({ _D_:'3', h:'12', m:'00' })
//T.is({ h:'03', m_:'10' }) && (T.D % 3 === 0)
//	&& Work('Backup', ()=>{ $`zx /Main/Server/Scripts/BackupAll.zx.mjs` });

T.is({ _D_:'9', h:'04', m_:'30' })
	&& Work('Certs', ()=>{ $`sh /Main/Server/Scripts/RenewCerts.sh` });

///////////////////////////////////////

(T.h=='00' && T.m=='00') && ResetJobs();
await sleep(7500);

};
