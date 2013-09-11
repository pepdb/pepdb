// define namespace to prevent loading js files multiple times
var pepdb = pepdb || {};
$.ajaxSetup({
  cache: true
});
var isFirstLoad = function(namesp, jsFile) {
  var isFirst = namesp.firstLoad === undefined;
  namesp.firstLoad = false;
/*
  if(!isFirst) {
    console.log("Warning: JS file included twice: " + jsFile);
  }
  */
  return isFirst;
};



$(document).ready(function(){
  var formAll = ["#all_lib", "#all_sel", "#all_ds", "#c_all_lib", "#r_all_lib" ];
  var propSelect = ['#l', '#s', '#ds', '#c', '#ts', '#tt', '#tc', '#ss', '#st', '#sc'];
  var propInput = ['#seq', '#blos', '#pl', '#sr', '#ralt', '#ragt', '#relt', '#regt', '#dlt', '#dgt'];

  /* get url parameter "name" or return "" if does not exist */
  function urlParam(name){
    var result = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    return result && unescape(result[1]) || ""; 
  }


  /* retrieve checkbox state from localStorage  */
  function checkCheckbox(storageName, itemID){
      if(localStorage[storageName]){
        var checkedItems = JSON.parse(localStorage[storageName]);
        var marked = false;
        checkedItems.forEach(function(element){
          if(element == itemID){
            marked = true;
            return false;
          }
        });
        return marked
      } 
  }
  
  /* save checkbox state to localStorage */
  function saveCheckbox(storageName, itemID, checkStatus){
    if(!localStorage[storageName]){
      var content = [];
      localStorage[storageName] = JSON.stringify(content);
    }
    var selectedItems = JSON.parse(localStorage[storageName]);
    if(checkStatus){
      selectedItems.push(itemID);
    } else {
      for (var elementCounter = 0; elementCounter < selectedItems.length; elementCounter = elementCounter +1){
        if(selectedItems[elementCounter] == itemID){
          selectedItems.splice(elementCounter, 1);
          break;
        }
      }
    }      
    localStorage[storageName] = JSON.stringify(selectedItems);
  } 


  $('#clear-button').click(function(){
    localStorage.clear();
    $('body').load(window.location.pathname);
  });
   
  $('#checkboxes :checkbox').each(function(){
    storage = $(this).attr("name").slice(0,-2);
    itemID = $(this).attr("id");
    $(this).prop('checked', checkCheckbox(storage, itemID));
  });
  
  /*(un)check all checkboxes on checking "all"*/  
  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        $(this).prop('checked', marked);
      });
    });  
  }); 
  
  $('#libform input:checkbox').click(function(){
    storage = $(this).attr("name");
    saveCheckbox(storage.slice(0,-2), $(this).attr("id"), this.checked); 
    alert("clicked");
    if(storage == "checked_lib[]"){
      localStorage.removeItem("checked_sel"); 
      localStorage.removeItem("checked_ds");

    } else if (storage == "checked_sel[]"){
      localStorage.removeItem("checked_ds");
    }
    $('#libform').submit();
  });
 
  $('#comp-library input:checkbox').click(function(){
    var checkedLibs = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_lib"){
        checkedLibs.push(elemVal);
      }
    });
    $('#comp-selection').load('/checklist',{checkedElem: checkedLibs, all_elem: 'c_all_sel', all_elem_val: 'all_sel', selector: 'sel', sec: 'c_' }, function(){
        $.getScript("/script/checkbox.js");
      } );
  });
  
  $('#ref-library input:checkbox').click(function(){
    var checkedLibs = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_lib"){
        checkedLibs.push(elemVal);
      }
    });
    $('#ref-selection').load('/checklist',{checkedElem: checkedLibs, all_elem: 'r_all_sel', all_elem_val: 'all_sel', selector: 'sel', sec: 'r_' }, function(){
        $.getScript("/script/checkbox.js");
      } );
  });

  


  $.each(propSelect, function(index, value){
    var paramName = $(value).attr('name');
    if(urlParam(paramName) == ""){
      $(value).prop('selectedIndex', -1);
    }
    $(value).on('beforeunload', function(){
      if ($(this).attr('selectedIndex') == -1)
        $(this).prop('name', '');
      });
    });

  $('#propsearch').submit(function(){
    $.each(propInput, function(index,value){
      if($(value).val() == ""){
        if(value == '#seq'){
          $('#type').attr('name', '');
        }
        $(value).attr('name', '');
      }
    });
  }); 
    
    
  $('#type').change(function(){
    
    $('#blossum').toggle();
  });





  /* --------------DataTables configuration----------------  */
  $('#select_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
  })
    .columnFilter();
  
  $('#show_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
  })
    .columnFilter();


  $('#select_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });
  
  $('#select_table tr:has(td)').click(function(){
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    $('body').load(route + "/" + selected_id); 
  });

  
  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });
  
  $('#show_table tr:has(td)').click(function(){
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    var first_choice =  $('#select_table').data('first-choice');
    if(first_choice != null ){
      $('body').load(route + "/" + first_choice + "/" + selected_id); 
    } else {
      $('body').load(route + "/" + selected_id);
    }
  });
 

  /* -----------jsTree configuration------------------- */  
  $('#clusterlist').bind("loaded.jstree", function(){
   var opennode = document.location.pathname.split("/").pop(); 
   $('#' + opennode).parents(".jstree-closed").each(function(){
      $('#clusterlist').jstree("open_node", this, false, true);
    }); 
  });  
 
  $('#clusterlist').bind('before.jstree', function(event,data){
    switch(data.plugin){
      case 'ui':
        if(!data.inst.is_leaf(data.args[0])){
          return false;
        }
        break;
      default:
        break;
    }
  }) 
    .jstree( {"plugins" : ["themes", "html_data"] })
    .delegate("a", "click", function(event, data){
   } );
  
  $('#disp-res').bind("loaded.jstree", function(){
   var opennode = document.location.pathname.split("/").pop(); 
   $('#' + opennode).parents(".jstree-closed").each(function(){
      $('#disp-res').jstree("open_node", this, false, true);
    }); 
  });  
 
  $('#disp-res').bind('before.jstree', function(event,data){
    switch(data.plugin){
      case 'ui':
        if(!data.inst.is_leaf(data.args[0])){
          return false;
        }
        break;
      default:
        break;
    }
  }) 
    .jstree( {"plugins" : ["themes", "html_data"] })
    .delegate("a", "click", function(event, data){
   } );


} );

