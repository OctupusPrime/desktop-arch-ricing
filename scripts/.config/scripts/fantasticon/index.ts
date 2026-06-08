import { FontAssetType, generateFonts } from 'fantasticon';
import { existsSync, mkdirSync, copyFileSync, rmSync } from 'fs';
import { join } from 'path';

const outputDir = './output';
const destFontsDir = '../../../../quickshell/.config/quickshell/assets/fonts';

if (!existsSync(outputDir)) {
    mkdirSync(outputDir, { recursive: true });
}

generateFonts({
    name: 'Icons',
    fontTypes: [FontAssetType.TTF],
    fontHeight: 512,
    normalize: true,
    descent: 0,
    inputDir: './icons',
    outputDir,
}).then(results => {
    console.log('\nIcon codepoints:');
    for (const [name, codepoint] of Object.entries(results.codepoints)) {
        console.log(`  ${name}: U+${codepoint.toString(16).toUpperCase().padStart(4, '0')}`);
    }

    const srcPath = join(outputDir, 'Icons.ttf');

    if (!existsSync(destFontsDir)) {
        mkdirSync(destFontsDir, { recursive: true });
    }

    copyFileSync(srcPath, join(destFontsDir, 'Icons.ttf'));
    console.log(`\nCopied Icons.ttf -> ${destFontsDir}`);

    rmSync(outputDir, { recursive: true, force: true });
    console.log(`Deleted ${outputDir}`);
});