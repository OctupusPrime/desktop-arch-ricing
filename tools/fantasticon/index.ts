import { FontAssetType, generateFonts } from 'fantasticon';
import { copyFileSync, mkdirSync, rmSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const toolDir = dirname(fileURLToPath(import.meta.url));
const outputDir = join(toolDir, 'output');
const quickshellDir = join(toolDir, '../../quickshell/.config/quickshell');
const iconsDir = join(quickshellDir, 'assets/icons');
const destFontPath = join(quickshellDir, 'assets/fonts/Icons.ttf');
const iconsQmlPath = join(quickshellDir, 'common/Icons.qml');

function toQmlPropertyName(iconName: string): string {
    return iconName.replace(/[-_]+(.)/g, (_, character: string) => character.toUpperCase());
}

function createIconsQml(codepoints: Record<string, number>): string {
    const properties = Object.entries(codepoints).map(([name, codepoint]) => {
        const propertyName = toQmlPropertyName(name);
        const unicodeEscape = codepoint.toString(16).toUpperCase().padStart(4, '0');

        return `    readonly property string ${propertyName}: "\\u${unicodeEscape}"`;
    });

    return `import QtQuick

QtObject {
${properties.join('\n')}
}
`;
}

async function buildIcons(): Promise<void> {
    mkdirSync(outputDir, { recursive: true });

    const results = await generateFonts({
        name: 'Icons',
        fontTypes: [FontAssetType.TTF],
        fontHeight: 512,
        normalize: true,
        descent: 0,
        inputDir: iconsDir,
        outputDir,
    });

    console.log('\nIcon codepoints:');
    for (const [name, codepoint] of Object.entries(results.codepoints)) {
        console.log(`  ${name}: U+${codepoint.toString(16).toUpperCase().padStart(4, '0')}`);
    }

    const srcPath = join(outputDir, 'Icons.ttf');

    mkdirSync(dirname(destFontPath), { recursive: true });
    copyFileSync(srcPath, destFontPath);
    writeFileSync(iconsQmlPath, createIconsQml(results.codepoints));

    rmSync(outputDir, { recursive: true, force: true });

    console.log(`\nGenerated ${destFontPath}`);
    console.log(`Generated ${iconsQmlPath}`);
}

buildIcons().catch(error => {
    rmSync(outputDir, { recursive: true, force: true });
    console.error(error);
    process.exitCode = 1;
});
