#!/usr/bin/env zx

let Name = $.env.Url.split('//')[1].split('/')[0].replaceAll('.', '-') + '.' + $.env.Url.split('/').slice(-2).join('.');
let GitBranch = ``;

if ($.env.Branch) {
	Name += `.${$.env.Branch}`;
	GitBranch = `--branch=${$.env.Branch}`;
};

cd(`/Main/Server/www/Drive/Repos`);
await $`git clone --depth=1 --recursive ${GitBranch} ${$.env.Url} ./${Name}`;
await $`tar cvJSf ./${Name}.tar.xz ./${Name}`;
await $`rm -rf ./${Name}`;
