function get_info(model)
{
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://together.jolla.com//api/v1/info/",true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE)
        {
            if ( xhr.status == 200)
            {
                var ginfo = JSON.parse(xhr.responseText);
                console.log(ginfo)
                model.append({"item" : "Groups: "+ginfo.groups})
                model.append({"item" : "Users: "+ginfo.users})
                model.append({"item" : "Questions: "+ginfo.questions})
                model.append({"item" : "Answers: "+ginfo.answers})
                model.append({"item" : "Comments: "+ginfo.comments})
            }
        }
    }
    xhr.send();

}

function get_questions(model)
{
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://together.jolla.com//api/v1/questions/",true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE)
        {
            if ( xhr.status == 200)
            {
                var qs = JSON.parse(xhr.responseText).questions;
                for (var index in qs)
                {
                    var ginfo = qs[index]
                    console.log(ginfo.title)
                    model.append({"title" : ginfo.title, "url" : ginfo.url})
                }
            }
        }
    }
    xhr.send();
}
