function [ ret ] = build_lt_data_file_name( N,tau,indx)
%BUILD_DATA_FILE_NAME Summary of this function goes here
%   Detailed explanation goes here
ret = ['N',num2str(N),'_net_simu_robust_siliton_tau_',num2str(tau),'_indx_',num2str(indx),'.mat'];
end

