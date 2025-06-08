# [whybhav.in](https://whybhav.in/)

hi, this is the repo of my website.

as someone with multiple years of experience in various frontend js frameworks, i decided to built this with jekyll because why the heck not?

## the site has

-   a minimalist design that i'll probably get bored of in a year (as is tradition)
-   a blog section with utterances comments
-   a photo gallery that makes me feel like i'm better at photography than i actually am
-   a "now" page that i'll update when i remember it exists
-   a responsive design that somehow works on both phones and computers?

## local setup

to run this locally:

```bash
# clone the repo
git clone https://github.com/codebhav/codebhav.github.io.git

# go into the project
cd codebhav.github.io

# install dependencies
bundle install

# start the jekyll server
bundle exec jekyll serve
```

## photo processing

i hate the idea of having to manually create different versions of the same photo for optimization, so i wrote a dainty shell script that you can run. it creates a low-res version of any new images you add to `/assets/images/photos/fullsize` and also automatically populates the necessary markdown files

```bash
chmod +x process_photos.sh
./process_photos.sh
```

note: you need to have ImageMagick installed.

## license

MIT licensed - see the LICENSE file for details.

## credits

special thanks to [adryd325](https://github.com/adryd325/oneko.js) for making a handy js script for having a cat follow your cursor around, which is objectively the best feature of this website.