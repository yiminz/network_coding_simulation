function [is_successfull statis] = sink_collect(context,M_rate)
%COLLECT ģ��sink�ڵ���ռ����̡�
%   ͳ����������
%   1.��������������--�����������޹ء�--�����ܺġ�
%   2.��ɽ������ռ��İ���,����Ĳ�ͬ�Ĳ����趨��N��M��k��������˷���û�����塣--�����������ܡ�
%   3.���������
%   
%   ע�����
%   1.�ں�����������ʱ����������У��Ƿ���Ի���������ʱ仯��ƽ������ͼ��
%   2.һ�α�������ݣ�����ͨ���ռ�������Զ�����á�
statis = 10;
is_successfull = 1;
return;
addpath('../../lib');

[decode_context context] = init_collect(context);
nodeNum = context.nodeNum;
grid_width = context.grid_width;
nx = context.nx;
ny = context.ny;
comRange = context.comRange;
k = context.k;

if M_rate < 0
    M_rate = 1.9;%���趨M_rateС��0ʱ����Ϊ�˵õ�������ۡ�������Ӧ���������ޣ�ֱ������ɹ�Ϊֹ����ˣ���һʼ���޷��ɹ����룬����������ѭ��������趨Ϊ1.9
end
recv_bound = ceil(nodeNum*M_rate);%�ռ������������
walker = randStrLineWalker(0,grid_width*nx,grid_width*ny,0,comRange);%ǰ���Ĳ���ΪcomRange
% figure(1);
% hold on;
% draw_situation( nodes,nodeNum,phyNBorMap );
while ~decode_context.is_finished
    pos = walker.move();
    node_list = getNodesInCircle(context,pos(1),pos(2),comRange);
    [context decode_context statis] = retrieve_data(context,decode_context,node_list,recv_bound);
    
    if decode_context.receive_counter >= recv_bound
        break;
    end
%     circle(pos,comRange);
end

%ͳ����
statis.recv_num = decode_context.receive_counter;
statis.num_decode_symbol = sum(decode_context.decoded_processed);

if statis.num_decode_symbol < k
    is_successfull = 0;
else
    is_successfull = 1;
end
end

function [context decode_context] = retrieve_data(context,decode_context,node_list,recv_bound)
    indx_bound = ListSize(node_list);
    for indx = 0:indx_bound-1
        node_id = ListGet(node_list,indx);
        if(~context.nodes(node_id).is_collected)
            pack_list =context. nodes(node_id).code_finished_mems;
            indx_bound2 = ListSize(pack_list);
            for indx2 = 0:indx_bound2-1
                pack = ListGet(pack_list,indx2);
                decode_context = sink_decode_new_pack(context,decode_context,pack);
                
                if decode_context.is_finished
                    return;
                end

                if decode_context.receive_counter >= recv_bound
                    return;
                end
            end
            context.nodes(node_id).is_collected = 1;
        end
    end
end

% function pos = move()
% global path;
% %----�����˶�
% % step_size = comRange/2;
% % delta_theta = step_size/r;
% % theta = theta + delta_theta;
% % 
% % r_rate = comRange/pi;
% % r = r + r_rate*delta_theta;       
% 
% %--����ɵ�
% % pos = grid_width.*[nx,ny].*rand(1,2);
% 
% end

% get nodes in circle =================================================
function node_list = getNodesInCircle(context,x,y,r)
    rect_list = nodesInRect(context,x,y,r);%�ӿ�����ٶȣ����پ�������
    node_list = nodesInCircle(context,rect_list,x,y,r);
end

function rect_list = nodesInRect(context,x,y,r)%Բ��(x,y)���뾶r��Բ�����о��Σ��ڵĵ�
nodeNum = context.nodeNum;
nodes = context.nodes;
rect_list = doubleLinkedList();
left_bound = x - r;
right_bound = x + r;
upper_bound = y + r;
lower_bound = y - r;
for indx = 1:nodeNum
    pos = nodes(indx).pos;
    if(pos(1) > left_bound && pos(1) < right_bound && pos(2) > lower_bound && pos(2) < upper_bound)
        ListInsert(rect_list,indx);
    end
end
end

function circle_list = nodesInCircle(context,rect_list,x,y,r)
    nodes = context.nodes;
    circle_list = doubleLinkedList();
    Op = [x,y];
    indx_bound = ListSize(rect_list);
    for indx = 0:indx_bound-1
        node_id = ListGet(rect_list,indx);
        pos = nodes(node_id).pos;
        if(norm(pos - Op) < r)
            ListInsert(circle_list,node_id);
        end
    end
end