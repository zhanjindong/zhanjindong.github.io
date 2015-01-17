require 'fileutils'

# Usage: rake build
# No arguments are allowed to avoid deleting wrong directories by mistake
desc "Build published Jekyll site to a pre-defined submodule"
task :build do

	DIR = './yizeng.github.io'

	# remove current _site folder and local production folder
	FileUtils.rm_rf("./_site", :verbose => true)
	FileUtils.rm_rf(Dir.glob("#{DIR}/*"), :verbose => true)

	# compile Compass project
	system "compass compile ./assets/css --output-style=compressed --no-line-comments --trace --force"

	# build Jekyll
	system "jekyll build"

	# remove redundant Compass project files from production
	FileUtils.rm_rf("./_site/assets/css/sass", :verbose => true)
	FileUtils.rm("./_site/assets/css/config.rb", :verbose => true)

	# copy the new _site to local production folder
	FileUtils.cp_r(Dir.glob("./_site/*"), "#{DIR}/", :verbose => true)

	# create and copy necessary files to production
	File.open("#{DIR}/CNAME", 'w+') {|f| f.write('yizeng.me') }
	FileUtils.touch("#{DIR}/.nojekyll", :verbose => true)
	FileUtils.cp('.gitignore', "#{DIR}/", :verbose => true)

	# compress html in _site
	Dir.glob("#{DIR}/**/*.html") do |html_file|
		puts "Compressing: #{html_file}"
		system "java -jar ./_rake/tools/htmlcompressor-1.5.3.jar --recursive --compress-js -o #{html_file} #{html_file}"
	end

	# re-compile Compass project without compressing for development
	system "compass compile ./assets/css --output-style=expanded --no-line-comments --trace --force"
end

# Usage: rake build_cn
# No arguments are allowed to avoid deleting wrong directories by mistake
desc "Build published Jekyll site to a pre-defined folder"
task :build_cn do
    DIR = '../cn.yizeng.me-gh-pages'

    # remove current _site folder and local production folder
    FileUtils.rm_rf("./_site", :verbose => true)
    FileUtils.rm_rf(Dir.glob("#{DIR}/*"), :verbose => true)

	# compile Compass project
	system "compass compile ./assets/css --output-style=compressed --no-line-comments --trace --force"

	# build Jekyll
	system "jekyll build"

	# copy the new _site to local production folder
	FileUtils.cp_r(Dir.glob("./_site/*"), "#{DIR}/", :verbose => true)

	# create and copy necessary files to production
	File.open("#{DIR}/CNAME", 'w+') {|f| f.write('cn.yizeng.me') }
	FileUtils.touch("#{DIR}/.nojekyll", :verbose => true)
	FileUtils.cp('.gitignore', "#{DIR}/", :verbose => true)

	# compress html in _site
	Dir.glob("#{DIR}/**/*.html") do |html_file|
		puts "Compressing: #{html_file}"
		system "java -jar ./_rake/tools/htmlcompressor-1.5.3.jar --recursive --compress-js -o #{html_file} #{html_file}"
	end

	# re-compile Compass project without compressing for development
	system "compass compile ./assets/css --output-style=expanded --no-line-comments --trace --force"
end