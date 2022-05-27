parent_dir=$(dirname $0)
diff_dir=$parent_dir/"diff"
mkdir -p $diff_dir

alg_dir=$parent_dir/"CommuneOrbitAlgorithmForMPhase"
im_dir=$parent_dir/"mPhaseImitationScripts"
im_exe=$parent_dir/"mPhaseImitation/mPhaseImitation.exe"
draw_py=$parent_dir/"CommuneOrbitAlgorithmForMPhase/draw.py"
kolmogorov_py=$parent_dir/"mPhaseImitationScripts/kolmogorov_diff.py"

alg_run=$alg_dir/"run.sh"
alg_py=$alg_dir/"algorithm_for_m_phase.py"
im_run=$im_dir/"run.sh"

alg_name_of_p_dir="p"
alg_p_dir=$alg_dir/$alg_name_of_p_dir
im_name_of_p_dir="results"
im_p_dir=$im_dir/$im_name_of_p_dir

alg_name_file=$(mktemp)
im_name_file=$(mktemp)
alg_path_file=$(mktemp)
im_path_file=$(mktemp)
im_max_orbit_size=$(mktemp)
to_compare_file=$(mktemp)

im_n=999999
test=$1
sigma=$2

test_base=$(basename $test .csv)
test_dir=$(dirname $test)
tmp_test_dir=$parent_dir/'temp_tests'
mkdir -p $tmp_test_dir
test_file_for_alg=$tmp_test_dir/$test_base'.csv'

echo $($im_run $im_exe $draw_py $sigma $im_n $test) > $im_name_file
sed 's,^,'$im_p_dir/',; s,$,.txt,' $im_name_file > $im_path_file
while read im_name
do
	cat $im_name | wc -l >> $im_max_orbit_size
done < $im_path_file
paste -d' ' $im_max_orbit_size $test > $test_file_for_alg

echo $($alg_run $alg_py $draw_py $sigma $test_file_for_alg) > $alg_name_file
sed 's,^,'$alg_p_dir/',; s,$,.txt,' $alg_name_file > $alg_path_file
paste -d' ' $alg_path_file $im_path_file > $to_compare_file

i=0
while read line
do
	temp_name=$diff_dir/$test_base'_'$i'.png'
	diff=$(python3 $kolmogorov_py $line $temp_name | tr -d \n) 
	true_name=$diff_dir/$test_base'_'$i'_'$diff'.png'
	mv $temp_name $true_name
	export i=$(($i+1))
done < $to_compare_file

rm $alg_name_file $im_name_file $alg_path_file $im_path_file $to_compare_file $im_max_orbit_size $test_file_for_alg



