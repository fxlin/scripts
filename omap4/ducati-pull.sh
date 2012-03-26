# pull from dev machine and put all files in the dir tree


echo ========== pull from dev machine ==========
#rsync  -avxP --include "*/" --include "*.xem3" --exclude "*"   xzl@felix.recg.rice.edu:/home/xzl/syslink2-samples/ .
#rsync  -avxP --delete --include "*/" --include "*.xem3" --exclude "*"   xzl@felix.recg.rice.edu:/home/xzl/syslink-honza/bios-syslink/ .

# sync w remote server
#rsync  -avxP --delete --include "*/" --include "*.xem3" --exclude "*"   xzl@felix.recg.rice.edu:/home/xzl/bios-syslink.reflex/packages/ti/omap/ .

# sync w local build
rsync  -avxP --delete --include "*/" --include "*.xem3" --exclude "*"   /home/xzl/bios-syslink.reflex/packages/ti/omap/ .

#echo ========== override the local old files ==========
#mkdir -p mirror
#find packages/ -name "*.xem3" -exec cp {} mirror/ \;
#md5sum mirror/*
