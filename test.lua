require "make_html"

fp = io.open("1-12.html", "w")
make_html(fp,1,12)
fp:close()

for i = 13,15 do
	print("Treating " .. i)
	fp = io.open(i .. ".html", "w")
	make_html(fp, i)
	fp:close()
end