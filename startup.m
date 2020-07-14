%{
startup.m
Francisco Javier Carrera Arias
10/02/2019

Adds fieldtrip as well as the tcp_udp toolbox to matlab prior to
neurofeedback from the RT_Entrainment_Toolbox directory
%}

function startup()
% Adds fieldtrip to MATLAB's path and set everything to its defaults
addpath(sprintf("%s/%s",pwd,"fieldtrip-20200224"))
addpath(sprintf("%s/%s",pwd,"tcp_udp_ip"))
ft_defaults
end

