import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "familytree.json";
    has famly_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["id"],
                family_name = family["family_name"]
            );
           
        } 
        take-->node::family_root;
        
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        filtered_members = [];
        for member in members {
            if (member["family_id"] == family_id) {
                filtered_members.list::append(member);
            }
        }
        for member in filtered_members {
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"],
                district = member["district"],
	            hobby = member["hobby"],
                movie =member["movie"]
            );
            famly_members.list::append(family_member);
        }
    }

    with exit {
        for member_1 in famly_members {
            for member_2 in famly_members {
                if (member_1.id  == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.l::append([here.days_to_birthday, here.age, here.name]);
        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
    }
}
walker find_interest_in_Movies {
    // returns the fmovie type related to each people
    has Movie_type_list = [];
    has people_name_list =[];
    has Movie_set =[];
    has Movie_log ={};
    has sub_list = [];
    has c =0;
    has count=0;
    has i =0;

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        Movie_type_list.l::append(here.movie);
        count =count+1;
        people_name_list.l::append(here.name);
    }
    with exit {
        for Movie_type in (Movie_type_list){
            if (Movie_type in Movie_set):c=c+1;
            else:Movie_set.l::append(Movie_type);
        }
        
        for Movie in Movie_set{
            sub_list=[];
            i=0;
            while (i < count){
                if(Movie_type_list[i]==Movie){
                    sub_list.l::append(people_name_list[i]);
                }
                i=i+1;

            }
            Movie_log[Movie]= sub_list;

        }


        std.out(Movie_set);
        std.out(Movie_log);
        report Movie_log;
        report Movie_set;
    }
}
walker find_different_hobby {
    // returns the different type of hobbies and list of people who are interested in that
    has hobby_name_list = [];
    has ppl_name_list =[];
    has hobby_set =[];
    has hobby_log ={};
    has sub_list = [];
    has c =0;
    has count=0;
    has i =0;

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        hobby_name_list.l::append(here.hobby);
        count =count+1;
        ppl_name_list.l::append(here.name);
    }
    with exit {
        for hob_name in (hobby_name_list){
            if (hob_name in hobby_set):c=c+1;
            else:hobby_set.l::append(hob_name);
        }
        
        for hob in hobby_set{
            sub_list=[];
            i=0;
            while (i < count){
                if(hobby_name_list[i]==hob){
                    sub_list.l::append(ppl_name_list[i]);
                }
                i=i+1;

            }
            hobby_log[hob]= sub_list;

        }


        std.out(hobby_set);
        std.out(hobby_log);
        report hobby_log;
        report hobby_set;
    }

}

walker same_district_people {
    // returns the peoples in same district, list of district
    has District_list = [];
    has people_name =[];
    has District =[];
    has District_log ={};
    has sub_list = [];
    has c =0;
    has count=0;
    has i =0;

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        District_list.l::append(here.district);
        count =count+1;
        people_name.l::append(here.name);
    }
    with exit {
        for disc in (District_list){
            if (disc in District):c=c+1;
            else:District.l::append(disc);
        }
        
        for disc in District{
            sub_list=[];
            i=0;
            while (i < count){
                if(District_list[i]==disc){
                    sub_list.l::append(people_name[i]);
                }
                i=i+1;

            }
            District_log[disc]= sub_list;

        }


        std.out(District);
        std.out(District_log);
        report District_log;
        report District;
    }
}

walker find_age_grp {
    // returns the People details in each age group
    has children_young_ppl = [];
    has working_age_ppl =[];
    has elderly_ppl =[];
    has age_grp ={};

   

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        
        if (!here.deceased) {
            here::get_age;
            here::get_population_into_age_grp;
            if (here.age < 15): children_young_ppl.l::append([here.age, here.name]);
            elif(here.age < 65): working_age_ppl.l::append([here.age, here.name]);
            else: elderly_ppl.l::append([here.age, here.name]);
            
        }
    }
    with exit {
        age_grp["Children and Young Age"] = children_young_ppl;
        age_grp["Working Age"] = working_age_ppl;
        age_grp["Elderly Age"] = elderly_ppl;
        std.out(age_grp);
        report age_grp;
    }

}
walker number_of_students{
    // returns the number of student and there name of the family
    has student = [];
    has count = 0;
    has std_dict = {};
    

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased){
            if (here.profession == "Student"){
             student.l::append([here.name]);
             count=count+1;
             }
        }
    }
    with exit {
        std_dict["Student name list"]=student;
        std_dict["Total number of student"]=count;
        std.out(std_dict);
        
        report student;
        }
}
walker number_of_engineers{
    // returns the upcoming birthdays of the family
    has ENGINEERS = [];
    has AREA = [];
    has ENG_dict = {};
    

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased){
            if (here.profession == "Electrical Engineer"){
             ENGINEERS.l::append([here.name]);
             AREA.l::append([here.district]);
             }
        }
    }
    with exit {
        ENG_dict["Engineer list"]=ENGINEERS;
        ENG_dict["area"]=AREA;
        std.out(ENG_dict);
        report ENGINEERS;
        report AREA;
        }
}