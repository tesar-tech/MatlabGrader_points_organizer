%% Script for organizing points from matlab grader
%Takes all the xlsx files in folder.
%These columns are expected: StudentName,ProblemTitle,x_Score
%This script does NOT filter late submissions.
%Export due date submissions only from matlab grader.

files = dir('*.xlsx');
student_table = table('size',[0,1],'variableTypes',"string",'variableNames',"Name");

for fileNum =1: length(files)%iterate over all of exported files
    file = files(fileNum);
    cviko = readtable(file.name);%get table
    
    max_body = cellfun(@(x) str2double(regexprep(x, '^[^(]*\D*(\d*).*b.*', '$1')),...%from "matie uloha 1 (3 body)" to => 3
        cviko.ProblemTitle, 'UniformOutput', true); 
    score = cellfun(@(x) str2double((erase(x,'%')))/100, cviko.x_Score, 'UniformOutput', true); %from "100 %" to => 1
    points_real = max_body .*score;%computing points from percentage and max points
    cviko.StudentName = string(cviko.StudentName);%convert to string - easier to work with.
    
    uniqueNames = unique(cviko.StudentName);%uniq names of student who submited solution in this cviko
    
    
    student_table.(file.name) = zeros(height(student_table),1);%add column to table (with name of current file)
    
    for ii =1: length(uniqueNames) %iterate over all students in this cviko
        indexy_studenta = find(cviko.StudentName== uniqueNames(ii));%find problems for student
        
        indx = find(student_table.Name == uniqueNames(ii));%find student in student_table
        if(isempty(indx))%student is not there
            student_table{end+1,1} = uniqueNames(ii);%create the student
            indx = height(student_table);
        end
        student_table{indx,fileNum+1} = sum(points_real(indexy_studenta));% all points for students from current cviko
    end
  
end

student_table
