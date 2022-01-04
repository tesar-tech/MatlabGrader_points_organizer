%% Script for organizing points from matlab grader

%Takes all the xlsx files in folder "files".
%These columns are expected: StudentName,ProblemTitle,x_Score
%This script does NOT filter late submissions.
%Export due date submissions only from matlab grader.
%It is necessary to have points in problem title like: První úloha (3 body)
    %otherwise it will produce NaNs
%Comment line 9 to take files from "files folder"

files = dir('files/*.xlsx');
% files = dir('*.xlsx');%demo only, 
student_table = table('size',[0,1],'variableTypes',"string",'variableNames',"Name");

for fileNum =1: length(files)%iterate over all of exported files
    file = files(fileNum);
    cviko = readtable(fullfile(file.folder, file.name));%get table
    
    max_body = cellfun(@(x) str2double(regexprep(x, '^[^(]*\D*(\d*).*b.*', '$1')),...%from "matie uloha 1 (3 body)" to => 3
        cviko.ProblemTitle, 'UniformOutput', true); 
    score = cellfun(@(x) str2double((erase(x,'%')))/100, cviko.x_Score, 'UniformOutput', true); %from "100 %" to => 1
    points_real = max_body .*score;%computing points from percentage and max points
    cviko.StudentName = string(cviko.StudentName);%convert to string - easier to work with.
    
    uniqueNames = unique(cviko.StudentName);%uniq names of student who submited solution in this cviko
    
    
    student_table.(file.name) = nan(height(student_table),1);%add column to table (with name of current file)
    
    for ii =1: length(uniqueNames) %iterate over all students in this cviko
        indexy_studenta = find(cviko.StudentName== uniqueNames(ii));%find problems for student
        
        indx = find(student_table.Name == uniqueNames(ii));%find student in student_table
        if(isempty(indx))%student is not there
            student_table{end+1,1} = uniqueNames(ii);%create the student
            indx = height(student_table);
            
            olderCviks = nan(1,fileNum+1-1);%current cviko is the first one for student
            if(~isempty(olderCviks))
              student_table{indx,2:fileNum+1} = olderCviks;%%this will produce NaNs inside cells where student did not submit
              %otherwise it would fill 0 to previous cviko (when current is cviko 2 it fills cviko 1 with nans)
            end
        end
        student_table{indx,fileNum+1} = sum(points_real(indexy_studenta));% all points for students from current cviko
    end
  
end

student_table.Sum = sum(student_table{:,2:end},2,'omitnan')

student_table
%%
writetable(student_table,'results.xlsx')
