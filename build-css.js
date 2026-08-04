const tailwindcss = require('tailwindcss');
const postcss = require('postcss');
const fs = require('fs');

const inputCss = fs.readFileSync('./input.css', 'utf8');

postcss([tailwindcss('./tailwind.config.js')])
  .process(inputCss, { from: undefined })
  .then(result => {
    fs.writeFileSync('./output.css', result.css);
    console.log('CSS compilé avec succès!');
  })
  .catch(err => {
    console.error('Erreur:', err);
  });
