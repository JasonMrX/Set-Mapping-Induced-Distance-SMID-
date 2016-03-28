function ComputeForPairs_LBMVEs
% the same as compute_allmetrics_forpairs(), except that the 
% GreedyComputationISmai8 is used instead of GreedyComputationISmai4.
%  Nov. 21. 

% Read pairs info from ConsensusPairFile, compute all metrics and store
% them into AllMetrics_SimFile

%  compute_allmetrics_forpairs('ConsensusPairs.dat', 'AllMetrics_Sim.dat')
    argc = 7;
    [ImagePair, OtherMetric] = ReadMetric('ComputeResult_moreDat_P2x2_MVE_LB8x8_EMD_HI_LB8x8Org_LBMVE.dat', argc) ;
    AllMetrics_SimFile = 'ComputeResult_moreDat_LB8x8Org_LBMVEs.dat';

%     Uncomment this part if you want to see a few comparison at the beginning
%     x = randperm(numel(ImagePair));
%     ImagePair(x) = ImagePair;
%     OtherMetric(x, :) = OtherMetric;
    
    foutsim=fopen(AllMetrics_SimFile, 'w');

    Npairs = length(ImagePair);

    for n = 1 : Npairs
        filename1 = ImagePair(n).name1 ;
        filename2 = ImagePair(n).name2 ;

        fprintf('%s %s\n', filename1, filename2);

%          [mDistPixel, mDistPixel8, mDistCost, mDistVar, mDistEntropy, success] = ComputeD2Complexity(filename1, filename2)  
%         [mDistDCT_ori, mDistDCTEntropy, MVs, success] = ComputeDCTComplexity_Entropy(filename1, filename2);  
        sizef = 264*264;
        [ X1oriL] = ReadResizeGrayImage(filename1, sizef);
        [ X2oriL] = ReadResizeGrayImage(filename2, sizef);
        [rowL, colL] = size(X1oriL);
        [row2, col2] = size(X2oriL);
        
        success = 1;
        if rowL ~= row2 || colL ~= col2
            success = 0;
        end
        
        if success
            format = ['%4d %16s %16s %3d   ', repmat('%10.4f ', 1, 1 + 24), '\n'];
            mvfilename = ['mv/', num2str(ImagePair(n).imageid)];
            mvArray = ComputeDCTMVEntropy(mvfilename, colL / 8 - 1, rowL / 8 - 1);
            fprintf(foutsim, format, ImagePair(n).imageid, filename1, filename2, ImagePair(n).vote, OtherMetric(n, 6), mvArray); 
%             dlmwrite(mvfilename, MVs);
%             disp(['writing motion vectors to ', mvfilename, '...']);
        end

    end
    fclose(foutsim);

    return ;
        
function [ImagePair, Metric] = ReadMetric(filename, argc)
  fin = fopen(filename, 'r');
  len = 1 ;
  pos1 = 1 ;
  pos2 = 1 ;
  while (len > 0)
      [imageid len] = fscanf(fin, '%d ', 1);
      if len > 0
         name1 = fscanf(fin, '%s ', 1);
         name2 = fscanf(fin, '%s ', 1);
         type = fscanf(fin, '%d ', 1);
         ImagePair(pos1).imageid = imageid;
         
         ImagePair(pos1).name1 = name1;
         ImagePair(pos1).name2 = name2;
         ImagePair(pos1).vote = type;
         Metric(pos1, 1 : argc) = fscanf(fin, '%f ', argc);
         pos1 = pos1 + 1 ;
      end
  end
  fclose(fin);
  