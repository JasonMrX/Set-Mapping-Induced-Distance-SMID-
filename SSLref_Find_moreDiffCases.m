function SSLref_Find_moreDiffCases
% Nov. 6
% Modified SSLref_4_tagsystem('test_SimScoreRough.dat') to find some pairs
% that are very different, to add to our total set which lacks diff-cases.    
     
     foutpairs = fopen('MoreDiffPairs.dat', 'w');

% Changed based on ProgressiveReview_SSLref(SSL_ref_in_Notview, SSL_ref_outfile, clusterfile)

      % note: we need to add an integer at the begining of the original
      % file. 
      SSL_in = ReadSimScoreListWithBeliefs('test_SimScoreRough.dat') ;
      
             %SSL(1).SimBelief = 0 ; % dummy codes
             %SSL(1).NosimBelief = 0 ; % dummy codes
             %SSL(1).NullBelief = 0 ; % dummy codes  
       
 
      Npair = length(SSL_in);
      
   imageid = 0 ;   
   UncertainCount = 0 ;
   
   count(1:3) = 0 ;
   
   for n=1:Npair
       
      
       ss = (SSL_in(n).NosimBelief+SSL_in(n).NullBelief)/(1+SSL_in(n).NullBelief) ;
       
       
       if SSL_in(n).simscore==0 && (SSL_in(n).NosimBelief>0.750 || SSL_in(n).SimBelief<0.25 || ss>0.7 )
      
           if  SSL_in(n).NosimBelief>0.905
                name1 = SSL_in(n).name1;
                name2 = SSL_in(n).name2;

                name1_s = name1(1:length(name1)-4); % get rid of .jpg
                newfilename = strcat(name1_s,'_', name2);

               fprintf(foutpairs, '%5d  %16s %16s %16s    %d\n', 0, newfilename, name1, name2, 2 );
                           % Notsim is noted as 0 in test_SimScoreRough.dat,
                           % yet in DB and hereafter it is noted as 2.
           end
           continue;
       end
       
       if SSL_in(n).simscore==1 && (ss>0.5 || SSL_in(n).SimBelief<0.75)
           continue ;
       end
           
       if SSL_in(n).simscore==0 && (ss<0.615 || SSL_in(n).SimBelief>0.7)
           continue ;
       end
       
       if SSL_in(n).simscore==-1  && ( SSL_in(n).SimBelief<0.59 ) %|| SSL_in(n).NosimBelief>0.15 )
           continue ;
       end
           

       
       
       %if SSL_in(n).simscore==0
       %    continue;
       %end
       
                       vote = 0 ;
                       if(SSL_in(n).simscore ==1) 
                           vote = 1 ;
                       end
                       if(SSL_in(n).simscore ==-1) 
                           vote = 3 ;
                       end
                       if(SSL_in(n).simscore ==0) 
                           vote = 2 ;    
                       end
                       count(vote) = count(vote) + 1 ;
           
       imageid = imageid + 1 ;
 
   
   end

   
   fclose(foutpairs);
  
      %imwrite(uint8(Img), strcat('ShowAll_', namelistfile, '.jpg'), 'Quality', 100) ;
function GetScoreForOnePairAndWriteOut(filename1, filename2, SSL_ref, SimScoreFilename, BeFalsePair) 

    if( strcmp(filename1, filename2) )
        AppendSimScoreFile(SimScoreFilename, filename1, filename2, 1.00, 1, 0,0);
    else
      ShowImg(filename1, 1) ;
      ShowImg(filename2, 2) ;
      SSL_get = GetSimScoreFromKeyboard(SSL_ref, BeFalsePair) ;
      AppendSimScoreBeliefFile(SimScoreFilename, filename1, filename2, SSL_get.simscore, SSL_get.SimBelief, SSL_get.NosimBelief, SSL_get.NullBelief) ;
      %AppendSimScoreFile(SimScoreFilename, filename1, filename2, scoreC)
    end
function SSL_get = GetSimScoreFromKeyboard(SSL_ref, BeFalsePair)
          
          SSL_get = SSL_ref ;

          if BeFalsePair
             SSL_get.SimBelief = SSL_ref.SimBelief * 0.1 ; 
             SSL_get.NosimBelief = 1 -  SSL_get.SimBelief ;
             SSL_get.NullBelief = 0 ;
          end
          
          
          fprintf('----------------------Please input your score of similarity   ');
          fprintf(' ( 100: the same  ');
          fprintf('  0: totally different) \n');
          fprintf('Ref: %5.3f    %5.3f    %5.3f \n',  SSL_get.SimBelief, SSL_get.NosimBelief, SSL_get.NullBelief);
          
          InvalidAnswer = 1 ;
          while InvalidAnswer
              
              if SSL_ref.SimBelief > 0                   
                 x = input(' Agree with the ref(y/n):  ', 's');             
          
                 if x(1)=='y' || x(1)=='Y'
                   %SSL_get = SSL_ref ;
                   InvalidAnswer=0 ;
                 else
                   x = input(' The probability of being similar is:  ', 's');
                   score = sscanf(x, '%f');
            
                   if score>=0 && score<=100
                     InvalidAnswer=0 ;
                     SSL_get.SimBelief = score/100;
                     SSL_get.NosimBelief = 1 - SSL_get.SimBelief ;
                     SSL_get.NullBelief = 0 ;
                   else
                     fprintf('Invalid answer. a value [0, 100] is expected.\n');
                   end                   
                 end
              else
                   x = input(' The probability of being similar is:  ', 's');
                   score = sscanf(x, '%f');
            
                   if score>=0 && score<=100
                     InvalidAnswer=0 ;
                     SSL_get.SimBelief = score/100;
                     SSL_get.NosimBelief = 1 - SSL_get.SimBelief ;
                     SSL_get.NullBelief = 0 ;
                   else
                     fprintf('Invalid answer. a value [0, 100] is expected.\n');
                   end                   
                  
              end
          end
          

function ShowImg(filename, idx)
if 0
   I = imread(filename);
   Y = I(:,:,1) ;
   [row, col] = size(Y);
   resizeratio = 512/row ;
   Yt = imresize(Y, resizeratio);   
   figure(idx)
      imshow(uint8(Yt));
      title(filename);
   pos = get(idx, 'position');
   pos(1) = (idx-1)*800 ;
   pos(2) = pos(2) + 100 ;
   set(idx,'position', pos);
else
   figure(idx)
      imshow(imresize(imread(filename), 0.1));
      title(filename);
   pos = get(idx, 'position');
   pos(1) = (idx-1)*750 ;
   pos(2) = pos(2) + 100 ;
   set(idx,'position', pos);
    
end
          
function AppendSimScoreBeliefFile(SimScoreFilename, filename1, filename2, simscore, SimBelief, NosimBelief, NullBelief)
  fin = fopen(SimScoreFilename, 'a');
  fprintf(fin, '%s  %s  %5.3f   %5.3f   %5.3f   %5.3f\n', filename1, filename2, simscore, SimBelief, NosimBelief, NullBelief);
  fclose(fin);
  
% pos ==0: not found
% pos is the position in SSL
function pos = CheckApairInSSL(SSL, filename1, filename2)
  
  NumPairs = length( SSL );
  pos = 0 ;
  
  for m = 1:NumPairs
      
      name1 = SSL(m).name1 ;
      name2 = SSL(m).name2 ;    
      
      if strcmp(name1, filename1) 
          if strcmp(name2, filename2)
              pos = m;
              return ;
          end
      end
      if strcmp(name1, filename2) 
          if strcmp(name2, filename1)
              pos = m ;
              return ;
          end
      end      
  end

function Cluster = ReadClusterfile(filename)
  fin = fopen(filename);
  
   if ~fin
       fprintf('Creating a new cluster file\n');
       
       fclose(fin);
       return ;
       
   end
   
    K = 0 ;
    count = 1;
    while count>0
      [M count] = fscanf(fin, '%d', 1) ;
      
      if count>0
          
        K = K + 1;
        
        Cluster(K).size = M ;        
        for m=1:M
          [name len] = fscanf(fin, '%s', 1) ;
          if len>0
              Cluster(K).name(m).str = name ;
          else
              fprintf('reading cluster file error\n');
          end
        end
        
      end
    end
  fclose(fin);     
  
function SSL_pairs = FromClusterToSSLPair(clusterfile)
  Cluster = ReadClusterfile(clusterfile);
  pairN = 0 ;
  N = length(Cluster);   
   for n=1:N       
      K = Cluster(n).size ;                 
      for k=1:K                    
          filename_1 = Cluster(n).name(k).str ;
          
          for j=k+1:K
              filename_2 = Cluster(n).name(j).str ;              
                  pairN = pairN + 1 ;
                  SSL_pairs( pairN ).name1 = filename_1 ;
                  SSL_pairs( pairN ).name2 = filename_2 ;
                  SSL_pairs( pairN ).simscore = -1 ; % 
                  SSL_pairs( pairN ).SimBelief = -1 ; % 
                  SSL_pairs( pairN ).NosimBelief = -1 ; % 
                  SSL_pairs( pairN ).NullBelief = -1 ; %               
          end              
      end      
   end
  
function SSL = ReadSimScoreListWithBeliefs(filename)
   fin = fopen(filename, 'r');

   if fin==-1
       fprintf('Open sim score list file error\n');
       SSL(1).name1 = 'XXXXX';
       SSL(1).name2 = 'XXXX' ;
       SSL(1).simscore = 0;
       SSL(1).SimBelief = 0 ; % dummy codes
       SSL(1).NosimBelief = 0 ; % dummy codes
       SSL(1).NullBelief = 0 ; % dummy codes  
       %fclose(fin);
       return ;
   end
   
    N = 0 ;
    len = 1;
    while len>0
      [name len] = fscanf(fin, '%s ', 1) ;
      
      if len>0
          
        N = N + 1;
        SSL(N).name1 = name ;
        
        [name len] = fscanf(fin, '%s ', 1) ;
        SSL(N).name2 = name ;
      
        ss = fscanf(fin, '%f', 4);
        
        SSL(N).simscore = ss(1);
        SSL(N).SimBelief = ss(2);
        SSL(N).NosimBelief = ss(3);
        SSL(N).NullBelief  = ss(4);
        
        %SSL(N).simscore = fscanf(fin, '%f', 1);
        %SSL(N).SimBelief = fscanf(fin, '%f', 1);
        %SSL(N).NosimBelief = fscanf(fin, '%f', 1);
        %SSL(N).NullBelief  = fscanf(fin, '%f', 1);
      end
    end
   
   fclose(fin);

function SSL = ReadSimScoreListWithBeliefsWithLength(filename)
   fin = fopen(filename, 'r');

   if fin==-1
       fprintf('Open sim score list file error\n');
       SSL(1).name1 = 'XXXXX';
       SSL(1).name2 = 'XXXX' ;
       SSL(1).simscore = 0;
       SSL(1).SimBelief = 0 ; % dummy codes
       SSL(1).NosimBelief = 0 ; % dummy codes
       SSL(1).NullBelief = 0 ; % dummy codes  
       %fclose(fin);
       return ;
   end
   
   
    N = fscanf(fin, '%d', 1) ;
   % SSL(1:N).name1 =[];
   % SSL(1:N).name2 = [];
   % SSL(1:N).simscore = 0;
   % SSL(1:N).SimBelief = 0;
   % SSL(1:N).NosimBelief = 0;
   % SSL(1:N).NullBelief = 0;
        
    SSL = struct('name1',{1:N}, 'name2',{1:N}, 'simscore', {1:N}, 'SimBelief', {1:N}, 'NosimBelief', {1:N}, 'NullBelief', {1:N});
    
    for loop=1:N
        
        %[name len] = fscanf(fin, '%s ', 1) ;
      
        SSL(loop).name1 = fscanf(fin, '%s ', 1) ;
        SSL(loop).name2 = fscanf(fin, '%s ', 1) ;
      
        ss = fscanf(fin, '%f', 4);
        
        SSL(loop).simscore = ss(1);
        SSL(loop).SimBelief = ss(2);
        SSL(loop).NosimBelief = ss(3);
        SSL(loop).NullBelief  = ss(4);
        
        %SSL(N).simscore = fscanf(fin, '%f', 1);
        %SSL(N).SimBelief = fscanf(fin, '%f', 1);
        %SSL(N).NosimBelief = fscanf(fin, '%f', 1);
        %SSL(N).NullBelief  = fscanf(fin, '%f', 1);    
    end
   
   fclose(fin);
  
function SSL = ReadSimScoreList(filename)
   fin = fopen(filename, 'r');

   if fin==-1
       fprintf('Open sim score list file error\n');
       SSL(1).name1 = 'XXXXX';
       SSL(1).name2 = 'XXXX' ;
       SSL(1).simscore = 0 ; % dummy codes
       %fclose(fin);
       return ;
   end
   
    N = 0 ;
    len = 1;
    while len>0
      [name len] = fscanf(fin, '%s ', 1) ;
      
      if len>0
          
        N = N + 1;
        SSL(N).name1 = name ;
        
        [name len] = fscanf(fin, '%s ', 1) ;
        SSL(N).name2 = name ;
        
        SSL(N).simscore = fscanf(fin, '%f', 1);
      end
    end
   
   fclose(fin);
