# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

echo "****************************************************************************************************"
echo "				Assuming proc file system is in /proc					"
echo "****************************************************************************************************"
echo ""

vol=$(cat /proc/partitions | grep sd[a-z][1-9] | tr -s ' ' | cut -d ' ' -f5)
echo "Found:		"$vol
echo ""

#mounted_vol=$(mount | grep sda | cut -d ' ' -f1 | sort | cut --b 6-)
#echo "Not mounting:   "$mounted_vol

for i in $vol
do
	#mount | grep $i >/dev/null
	mount_point=`mount | grep $i`
	if [ $? = 0 ]
	then
		echo ""$i" is already mounted on "`echo $mount_point | cut -d ' ' -f3`""
	else
		# umask=0022 works for FAT and NTFS - executable permission can
		# be set for files in these FS also with this umask value.
		# gvfs-mount does not have option(s) for this so using udisks.
		# Modified on 18 Feb 2012 to use udisks instead of gvfs-mount.
		#
		# Info taken from the link
		# http://superuser.com/questions/134438/how-to-set-default-permissions-for-automounted-fat-drives-in-ubuntu-9-10
		udisks --mount /dev/$i --mount-options "umask=0022"
		# gvfs-mount -d /dev/$i 2>&1 /dev/null
		# gnome-mount --device /dev/$i 2&>1 /dev/null
		if [ $? = 0 ]
		then
			is_mounted=`mount | grep $i`
			if [ $? = 0 ]
			then
				echo "Successfully mounted /dev/$i"
			else
				udisks --mount /dev/$i
				if [ $? = 0 ]
				then
					echo "Successfully mounted /dev/$i"
				else
					echo "Mounting /dev/$i failed"
				fi
			fi
		else			
			echo "Mounting /dev/$i failed"
		fi
		# Modified on Nov 13 2011 to use gvfs-mount instead of gnome-mount
		# gnome-mount --device /dev/$i
	fi
done

echo ""

exit 0
