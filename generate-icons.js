const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

const srcIcon = path.join(__dirname, 'icons', 'icon.png');
const androidRes = path.join(__dirname, 'android', 'app', 'src', 'main', 'res');

// Standard Android launcher icon sizes
const sizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

// Adaptive icon foreground sizes (108dp baseline)
const adaptiveForeground = {
  'mipmap-mdpi': 108,
  'mipmap-hdpi': 162,
  'mipmap-xhdpi': 216,
  'mipmap-xxhdpi': 324,
  'mipmap-xxxhdpi': 432,
};

async function generateIcons() {
  console.log('Generating Android launcher icons from:', srcIcon);

  // Standard launcher icons
  for (const [folder, size] of Object.entries(sizes)) {
    const dir = path.join(androidRes, folder);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    await sharp(srcIcon).resize(size, size).png().toFile(path.join(dir, 'ic_launcher.png'));
    await sharp(srcIcon).resize(size, size).png().toFile(path.join(dir, 'ic_launcher_round.png'));
    console.log(`  ${folder} (${size}x${size})`);
  }

  // Adaptive icon foregrounds (with 25% inset for safe zone)
  for (const [folder, size] of Object.entries(adaptiveForeground)) {
    const dir = path.join(androidRes, folder);
    const inset = Math.floor(size * 0.25);
    await sharp(srcIcon)
      .resize(size - inset * 2, size - inset * 2)
      .extend({ top: inset, bottom: inset, left: inset, right: inset, background: { r: 0, g: 0, b: 0, alpha: 0 } })
      .png()
      .toFile(path.join(dir, 'ic_launcher_foreground.png'));
    console.log(`  ${folder}/ic_launcher_foreground.png (${size}x${size})`);
  }

  // Generate logo for splash
  const splashDir = path.join(androidRes, 'drawable');
  if (!fs.existsSync(splashDir)) fs.mkdirSync(splashDir, { recursive: true });
  await sharp(srcIcon)
    .resize(288, 288, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toFile(path.join(splashDir, 'ic_launcher_foreground.png'));

  console.log('\n✓ All icons generated!');
}

generateIcons().catch(console.error);
