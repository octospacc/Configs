#!/usr/bin/env zx

let Inputs = $.env.Document;

//let Output = Input.split('.').slice(0,-1).join('.') + '.out.' + Input.split('.').slice(-1)[0];
let Output = `${Inputs}.out/` + Inputs.split('/').slice(-1)[0];
await fs.mkdir(`${Inputs}.out`);

// TODO: if inputs is zipped folder, extract it and iterate
Inputs = [Inputs];

for (let Input of Inputs) {
	let Ext = Input.split('.').slice(-1)[0];
	let Intermid = Input;

	let Background = `${Input}.bg.${Ext}`;
	await fs.copy(Input, Background);

	await $`convert ${Input} -modulate ${$.env.Brightness} ${Intermid}`;

	if ($.env.FilterMode.startsWith('Compose:')) {
		await $`convert ${Background} -fill ${$.env.FilterColor} -colorize 100% ${Background}`;
		await $`composite -compose ${$.env.FilterMode.split(':')[1].trim()} ${Input} ${Background} ${Intermid}`;
	};

	await fs.copy(Intermid, Output);

	let WhichPdf = await $`lp -d PDF -o scaling=${$.env.Scaling} -o position=${$.env.Position} ${Intermid}`;
	WhichPdf = WhichPdf.toString().split('request id is PDF-').slice(-1)[0].split(' ')[0];
	WhichPdf = await retry(999, expBackoff(), () => $`ls ~/PDF/*-job_${WhichPdf}.pdf`);
	WhichPdf = WhichPdf.toString().trim();

	let OutputPdf = `${Output}.cups-pdf.pdf`;
	// TODO: Actually wait for file to be surely moved, don't use a constant wait
	await sleep(1500);
	await fs.rename(WhichPdf, OutputPdf);
	await sleep(1500);

	if ($.env.PrintJob === 'Yes') {
		await $`lp -d EPSON_WF-2510_Series ${OutputPdf}`;
		echo`<audio src="//hlb0.octt.eu.org/Res/NokiaArabic-Short.mp3" autoplay="autoplay" controls="controls"></audio>`;
	};
};
