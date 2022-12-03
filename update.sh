quarto render main.qmd
cd ../../
quarto render
echo angelfeliz.com > docs/CNAME
git add .
git commit
git push origin main