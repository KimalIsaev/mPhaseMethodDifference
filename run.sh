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
to_compare_file=$(mktemp)

im_n=$1
x_n=$2
percision=$3
test=$4

echo $alg_run $alg_py $draw_py $x_n $percision $test
$alg_run $alg_py $draw_py $x_n $percision $test > $alg_name_file
$im_run $im_exe $draw_py $im_n $test > $im_name_file
cat $alg_name_file
sed 's,^,'$alg_p_dir/',; s,$,.txt,' $alg_name_file > $alg_path_file
sed 's,^,'$im_p_dir/',; s,$,.txt,' $im_name_file > $im_path_file
cat $alg_path_file
paste -d' ' $alg_path_file $im_path_file > $to_compare_file

cat $to_compare_file

i=0
while read line
do
	temp_name=$diff_dir/$(basename $test .csv)'_'$i'.png'
	diff=$(python3 $kolmogorov_py $line $temp_name | tr -d \n) 
	true_name=$diff_dir/$(basename $test .csv)'_'$i'_'$diff'.png'
	mv $temp_name $true_name
	export i=$(($i+1))
done < $to_compare_file

rm $alg_name_file $im_name_file $alg_path_file $im_path_file $to_compare_file



