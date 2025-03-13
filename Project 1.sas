/**************** Anna Rakes and Lexi Waller ****************/
/************************* STS 3270 *************************/


/* Import Baseline Patient Sheet */
proc import file="/home/u62154086/my_shared_file_links/mweaver110/STS3270/DataFiles/ProjectData/BetterStudyData.xlsx"
            out=Baseline
            dbms=xlsx
            replace;
            sheet= "baseline";
run;

/* Import Follow-Up Visit Sheet */      
proc import file="/home/u62154086/my_shared_file_links/mweaver110/STS3270/DataFiles/ProjectData/BetterStudyData.xlsx"
            out=FollowUpVisit
            dbms=xlsx
            replace;
            sheet= "followup";
run;




/* Set baseline data into datastep to work with */
data Base;
	set baseline;
	
/* Part 1: Create sitetype variable */
	if (medsite = "HBH") or (medsite = "UNC ED") or (medsite = "Rex") then sitetype = "ER";
		else if medsite = "OrthoNow" then sitetype = "UC";
		
/* Part 2: Create age variable */
	age = floor((screendate - birthdate)/365.25);
	
/* Create 0/1 Male variable for gender */
	if sex = 1 then Male = 1;
	else Male = 0;	
	
/* Part 3: Combine all race variables into one Race variable */
	if race_asian = 1 then race = "Asian";
		else if race_black = 1 then race = "Black";
		else if race_white = 1 then race = "White";
		else race = "Other";
		
/* Part 4: Create education variable */
	length education $21;
	if educ <= 1 then education = "High School or Less";
		else education = "At least some college";
		
/* Use array to change missing values to .  */ 
	array pain [4] painworst painleast painavg painnow;
	do i=1 to 4;
        if pain[i] = 55 then pain[i] = .;
    end;
    
/* Part 5: Calculate BaselinePainSev */
	if NMISS(painworst, painleast, painavg, painnow) <= 2 then BaselinePainSev = mean(painworst, painleast, painavg, painnow);
	
/* Part 6: Calculate BMI*/	
	BMI = (weight*703)/height**2;
	
/* Part 7: Create opioids variable */	
	if index(upcase(painmeds), "OPIOID") = 1 then Opioids= "Yes";
	else Opioids = "No";	
run;

	


/* Sort both data sets by recordID so that I can create variables and merge them back together later */
proc sort data=followUpVisit;
by recordid;
run;

proc sort data=base;
by recordid;
run;



/* Set follow up visit data, changing missing values to . using array */
data followUp;
	set followupVisit;
	by recordid;
	array pain [4] painworst painleast painavg painnow;
	do i=1 to 4;
        if pain[i] = 55 then pain[i] = .;
    end;
    
/* Part 12: Calculate PainSeverity, same as BaselinePainSev */
	if NMISS(painworst, painleast, painavg, painnow) <= 2 then PainSeverity = mean(painworst, painleast, painavg, painnow);
run;



/* Part 8: Calculate PainSevFuMin and PainSevFuMax by using ODS */
ods output summary = minmaxPain;
proc means data= followUp max min;
	by recordid;
	var painseverity;
run;

/* Merge PainSevFuMin and PainSevFuMax from ods summary into baseline data set */
data base;
	merge base minmaxpain (rename = (painseverity_Min = PainSevFuMin painseverity_Max = PainSevFuMax));
	by recordid;
run;




/* Sort the followup dataset by recordid and DAY */
proc sort data= followup;
	by recordid day;
run; 

/* Part 9: Calculate FinalPainSev */
data finalPain;
	set followUp;
	by recordid day;
	lastpain = last.recordid;
	if lastpain = 1 then FinalPainSev = painseverity;
	if lastpain=1;
run;

/* Merge FinalPainSev variable back into baseline dataset */
data base;
	merge base finalpain (keep = finalpainsev recordid day);
	by recordid;
run;





/* Create new dataset that merges a few variables from baseline into followup data  */
data callBack;
	merge base (keep = recordid screendate trtgroup) followup;
	by recordid;
	
/* Part 10: Create ActualDay variable */
	ActualDay = calldate-screendate;
	
/* Part 11: Create Within2Weeks variable */
	if (abs(actualday-day))<= 14 then Within2Weeks = 1;
	else within2weeks = 0;
	
/* Use array to turn missing values into a . */
	array pain [7] painint_general painint_mood  painint_walk painint_work painint_relate painint_sleep painint_life;
	do i=1 to 7;
        if pain[i] = 55 then pain[i] = .;
    end;
    
/* Part 13: Calculate PainInterference variable */
	if NMISS(painint_general, painint_mood, painint_walk, painint_work, painint_relate, painint_sleep, painint_life) 
	<= 3 then PainInterference = mean(painint_general, painint_mood, painint_walk, painint_work, painint_relate, painint_sleep, painint_life);
	
/* Part 14: Calculate CombinedPain variable */
	if painInterference ne "." and painseverity ne "." then CombinedPain = mean(painseverity, painInterference);
run;





/**************Look at 2 final datasets, keep, drop, rename, and add labels to variables**************/
data finalBaseLine;
	set base;
	keep recordid trtgroup screendate eth_hispanic sitetype age male race education baselinepainsev bmi opioids painsevfumax
	painsevfumin finalpainsev;
	label recordid = "Participant ID" trtgroup = "Treatment Group" screendate = "Screening Date" eth_hispanic = "Hispanic Ethnicity"
		sitetype = "Enrollment Site Type" age = "Participant Age at time of Study Entry" male = "1 if male, 0 if female" race = "Participant Race"
		education = "Education Category" BaselinePainSev = "Baseline Pain Severity" BMI = "Body Mass Index" Opioids = "Was participant prescribed opioids? Yes or No" 
		PainSevFuMax = "Maximum Pain Severity During Follow-Up" PainSevFuMin = "Minimum Pain Severity During Follow-Up" FinalPainSev = 
		"Pain Severity at Participant's final Follow-Up";
run;

proc contents data = finalBaseLine order=varnum;
run;

data finalVisitFollowUp;
	set callBack;
	keep recordid trtgroup day actualday within2weeks painseverity paininterference combinedpain;
	label recordid = "Participant ID" trtgroup = "Treatment Group" day = "Nominal Follow-Up Visit Day" actualday = "Actual Follow-Up Visit Day"
	within2weeks = "1 if actual day within 2 weeks of nominal, 0 otherwise" painseverity = "Pain Severity" PainInterference = "Pain Interference"
	combinedpain = "Combined Pain Score";
run;
proc contents data = finalVisitFollowUp order=varnum;
run;



/***************** Create Permanent Datasets *****************/
libname STSData "/home/u62154086/STS 3270";
data STSData.Participant;
	set finalBaseLine;
run;


data STSData.Visits;
	set finalVisitFollowUp;
run;
 
 






         