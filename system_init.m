function simu_context = system_init(simu_context)
%INIT_SIMU Ϊ����ϵͳ��ʼ�����泡����
%  ��������������ݡ�����ϵͳ��Ҫ�õ���ͼ��
%��ʼ�����
addpath('lib\data_structure');
addpath('lib');
%<global init>
simu_context = put_nodes_in_grid(simu_context);
simu_context = construct_phy_NBor_map(simu_context);

%ȫ�ֿ����ź�
simu_context.is_code_finished = 1;
end

%
%node mem size:�ܻ���ռ�
%refuse reception threshold:������ռ�ö���ʱ���ܾ������°�
%code redundence:ÿ���������ɶ��ٸ��ظ����
%
function simu_context = put_nodes_in_grid(simu_context)
%Ŀ�깦�ܣ�
%�ھ����ܽӽ������ε�ƽ��ռ��ڣ�����Ԥ���ܶȷ������н�㡣Ϊ�ˣ�������΢�޸Ľڵ��������
%Ҫ������Ϊ�������ˡ�
%Ҫ���㱻��ʼ��������Ŀ��ȸ�����ͬ����������ͬԭʼ���ŵ������
    nx = simu_context.nx;
    ny = simu_context.ny;
    nodeNum = simu_context.nodeNum;
    code_redundence = simu_context.code_redundence;
    comRange = simu_context.comRange;
    sensor_density = simu_context.sensor_density;
    grid_width = simu_context.grid_width;
    tau = simu_context.tau;

    for k=1:nodeNum
        nodes(k).id = k;
        
        %�趨λ��
        x = mod(k-1,nx)*grid_width;
        y = floor((k-1)/nx)*grid_width;
        nodes(k).pos = [x,y];
        
        %<��ʼ�����>-----------------------------------------------
        %--��һ�α���ǰ�����贫�������
        pack.left_hop = tau;
        pack.hop_count = int32(0);
        
        %--�������ϵ��
        tmp = int32(zeros(1,nodeNum));
        tmp(k) = int32(1);  
        pack.coeffs = tmp;
        
        %--����b����ʼ�������롰δ��ɱ�������������С�
        list = doubleLinkedList();
        for counter=1:code_redundence
            pack.left_degree = int32(get_target_degree(simu_context) - 1);%�������ķ��ŷ�����
            ListInsert(list, pack);
        end
        nodes(k).coding_mems = list;
        %--��ʼ��������ɱ������������
        nodes(k).code_finished_mems = doubleLinkedList();
        %</��ʼ�����>---------------------------------------------

        nodes(k).is_busy = 0;%used to media access control
        nodes(k).is_collected = 0;
    end
    simu_context.nodes = nodes;
end
function targetDegree = get_target_degree(simu_context)
    distribution = simu_context.distribution;
    nodeNum = simu_context.nodeNum;

    rand_scalar = rand();
    for indx = 1:nodeNum
       if rand_scalar < distribution(indx)
           targetDegree = indx;
           break;
       else
           rand_scalar = rand_scalar - distribution(indx);
       end
    end
end
%density: comRange^2*nodeNum/area
% function init_nodes_random()
% global nodes nodeNum density comRange nodeMemSize;
% area_width = floor(sqrt(comRange.^2*nodeNum/density));
% %id
% %pos
% %neigbor
% %mem
% %hopRank
% for k=1:nodeNum
%     nodes(k).id = k;
%     nodes(k).pos = randi(area_width,1,2);
%     nodes(k).neigborNum = 0;%������ڽ����ͨ�Ź����и��£����������Ϊʹ���ʲ����硣
%     
%     tmp = zeros(1,nodeNum);
%     tmp(k) = 1;
%     nodes(k).mem = ones(nodeMemSize,1)*tmp;%��k����������������k��mem�ϴ洢�İ���ϵ��������
%     nodes(k).hopRank = -1;
% end
% nodes(1).pos = [0,0];%��sink�������½�
% end

function simu_context = construct_phy_NBor_map(simu_context)
    nodes = simu_context.nodes;
    comRange = simu_context.comRange;
    nodeNum = simu_context.nodeNum;

    phyNBorMap = zeros(nodeNum,nodeNum);
    for k1 = 1:nodeNum
        for k2 = k1+1:nodeNum
            phyNBorMap(k1,k2) = (norm(nodes(k1).pos - nodes(k2).pos) < comRange);
        end
    end
    phyNBorMap = phyNBorMap + phyNBorMap';
    
    simu_context.max_nb_num = max(sum(phyNBorMap,1));
    simu_context.phyNBorMap = phyNBorMap;
end