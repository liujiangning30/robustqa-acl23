COLBERT=ColBERT
datasplit=test
model_path=/cpfs01/user/liujiangning/.cache/huggingface/hub/models--colbert-ir--colbertv2.0/snapshots/c1e84128e85ef755c096a95bdb06b47793b13acf
domains=(lifestyle recreation technology science writing)
for i in "${!domains[@]}"; do
    echo converting ${domains[i]}
    python code/convert_to_colbert.py \
        --data ${domains[i]} \
        --split ${datasplit} \
        --data_dir data/lotte \
        --output_dir $COLBERT/data
done

for i in "${!domains[@]}"; do
    echo construct index for ${domains[i]}
    export CUDA_VISIBLE_DEVICES='1'
    python colbert_scripts/run_colbert.py \
        --dataroot ${COLBERT}/data/ \
        --dataset  ${domains[i]} \
        --split ${datasplit} \
        --model  ${model_path} \
        --index
done

for i in "${!domains[@]}"; do
    echo searching for ${domains[i]}
    export CUDA_VISIBLE_DEVICES='1'
    python colbert_scripts/run_colbert.py \
        --dataroot ${COLBERT}/data/ \
        --dataset  ${domains[i]} \
        --split ${datasplit} \
        --model ${model_path} \
        --search
done

for i in "${!domains[@]}"; do
    echo ranking for ${domains[i]}
    export CUDA_VISIBLE_DEVICES='1'
    python colbert_scripts/run_colbert.py \
        --dataroot ${COLBERT}/data/ \
        --dataset  ${domains[i]} \
        --split ${datasplit} \
        --model ${model_path} \
        --eval \
        --ranking_file experiments/${domains[i]}/colbert_scripts.run_colbert/**/${domains[i]}-${datasplit}-ranking.tsv
done