/********** Anna Rakes and Lexi Waller **********/
/******************* STS 3270 *******************/

libname Data "/home/u62154086/my_shared_file_links/mweaver110/STS3270/DataFiles/ProjectData";

/* Create dataset for figure 1 & format categorical gender variable */
proc format;
value genFmt 1 = "Male"
			 0 = "Female"
			 ;
run;


data participant;
	set data.participant;
	gender = male;
	format gender genfmt.;
run;


/* Create Figure 1 */
proc sgplot data = participant;
	vbox baselinepainsev / category=race group = gender name="Gender";
	
	xaxis values=("Black" "White" "Asian" "Other") labelattrs=(size=12pt) valueattrs=(size=12pt);
	
	yaxis values= (0 to 10 by 2) labelattrs=(size=12pt) valueattrs=(size=12pt);
	
	title justify = left height = 12pt
		  "Figure 1. Distribution of Baseline Pain Severity, by Race and Gender";
	
	keylegend "Gender" / location = inside position = bottomleft valueattrs=(size=12pt);
run;



/*****************************************************************/

/* Get treatment group means */
ods output summary = trtMean;
proc means data = data.visits mean;
	var painseverity;
	class day trtgroup;
run;

/* Get overall mean */
ods output summary = overallMean;
proc means data = data.visits mean;
	var painseverity;
	class day;
run;

/* Merge treatment group mean and overall mean into one dataset */
data together;
	set trtmean overallMean;
	if trtgroup = "" then trtgroup = "Overall Mean";
/* Create layers for visualization */
	if trtgroup = "Control" then group1 = painseverity_mean;
	if trtgroup = "Video Only" then group2 = painseverity_mean;
	if trtgroup = "Full Intervention" then group3 = painseverity_mean;
	if trtgroup = "Overall Mean" then group4 = painseverity_mean;
run;


/* Create figure 2 */
proc sgplot data = together;
series x=day y = group1 / lineattrs= (color = red) markers markerattrs= (symbol = diamondfilled color=red)
						  name = "c" legendlabel="Control";

series x=day y = group2 / lineattrs = (color = blue) markers markerattrs= (symbol = diamondfilled color=blue)
					      name = "v" legendlabel= "Video Only";

series x=day y = group3 / lineattrs = (color = purple) markers markerattrs= (symbol = diamondfilled color=purple)
						  name = "f" legendlabel= "Full Intervention";

series x=day y = group4 / lineattrs = (color = black pattern = shortdash)
						  name = "m" legendlabel= "Overall Mean";

yaxis label = "Average Pain Severity" values = (0 to 4) labelattrs=(size=12pt) valueattrs=(size=12pt);

xaxis values = (0 30 90 180 365) labelattrs=(size=12pt) valueattrs=(size=12pt);

keylegend "c" "v" "f" "m" / across = 1 location = inside position = bottomright title = "Group" valueattrs=(size=12pt) 
							titleattrs= (size=12pt);

title1 justify = left height = 12pt "Figure 2. Average Pain Severity across Follow-Up Visits, by Treatment Group";

run; 





