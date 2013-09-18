// define namespace to prevent loading js files multiple times
var pepdb = pepdb || {};
/*
$.ajaxSetup({
  cache: true
});
*/
var isFirstLoad = function(namesp, jsFile) {
  var isFirst = namesp.firstLoad === undefined;
  namesp.firstLoad = false;
  
  return isFirst;
};

/* get url parameter "name" or return "" if does not exist */
function urlParam(name){
  var result = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
  return result && unescape(result[1]) || ""; 
}

$(document).ready(function(){
  var formAll = ["#all_lib", "#all_sel", "#all_ds", "#c_all_lib", "#r_all_lib" ];
  var propSelect = ['#l', '#s', '#ds', '#c', '#ts', '#tt', '#tc', '#ss', '#st', '#sc'];
  var propInput = ['#seq', '#blos', '#pl', '#sr', '#ralt', '#ragt', '#relt', '#regt', '#dlt', '#dgt'];

  $('#addlink').button();  
  $('#editlink').button();  
  $('#navigation').menu();
  $('#clear-button').click(function(){
    $('body').load(window.location.pathname);
  });
   

  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        $(this).prop('checked', marked);
      });
    });  
  }); 
  
  $('#comp-library input:checkbox').click(function(){
    var checkedLibs = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_lib"){
        checkedLibs.push(elemVal);
      }
    });
    $('#comp-selection').load('/checklist',{checkedElem: checkedLibs, allElem: 'c_all_sel', allElemVal: 'all_sel', selector: 'sel', sec: 'c_', elemName: 'sels[]' }, function(){
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
    $('#ref-selection').load('/checklist',{checkedElem: checkedLibs, allElem: 'r_all_sel', allElemVal: 'all_sel', selector: 'sel', sec: 'r_', elemName: 'sels[]' }, function(){
        $.getScript("/script/checkbox.js");
      } );
  });

   $('#compdata').submit(function(){
    if($('#results').is(':visible')){
      $('#results').toggle();
    }
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      success: function(response){
        $('#results').html(response);
        $.getScript('/script/tableinit.js', function(){
          $('#results').toggle();
        });
      }
    });
    return false;
  });
   
  $('#cl-search').submit(function(){
    if($('#results').is(':visible')){
      $('#results').toggle();
    }
    if($('#clsearch').is(':visible')){
      $('#clsearch').toggle();
    }
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      success: function(response){
        $('#results').html(response);
        $.getScript('/script/tableinit.js', function(){
          $('#results').toggle();
        });
      }
    });
    return false;
  });

  $('#datatype').ready(function(){
    $("#dataform").load('/addlibrary', function(){
      $('#adddata').submit(function(){
        /*  if($('#validerrors').is(':visible')){
          $('#validerrors').toggle();
        }*/
        $.ajax({
          data: $(this).serialize(),
          type: $(this).attr('method'),
          url: $(this).attr('action'),
          success: function(response){
            $('#valerrors').html(response);
            }
          });
        return false;
      });
    });
  });

    $('#datatype').change(function(){
      var selected = $(this).children("option:selected").text();
      if(selected == "sequencing dataset"){
        selected = "dataset";
      }
      if(selected == "motif list"){
        selected = "motif";
      }
      $("#dataform").load('/add'+ selected, function(){
        var boxNames = ['#dlibname', '#dselname', '#ddsname', '#dspecies', '#schemes', '#encodinglist'];

        $.each(boxNames, function(index, value){
          $(value).prop('selectedIndex', -1);
        });

       $('#adddata').submit(function(){
      /*  if($('#validerrors').is(':visible')){
          $('#validerrors').toggle();
        }*/
        $.ajax({
          data: $(this).serialize(),
          type: $(this).attr('method'),
          url: $(this).attr('action'),
          success: function(response){
            $('#valerrors').html(response);
            }
          });
        return false;
        });

        $('#dspecies').change(function(){
          var valSel = $(this).children("option:selected").text();
          $.get('/formdrop', {columnname: "tissue", selected1: valSel, table:"targets", where1:"species", boxID:"dtissue"}, function(data){
            $('#dtissue').html(data);
            $('#dtissue').prop('selectedIndex', -1);
            $('#dcell').html('');
          });
        });
        $('#dtissue').change(function(){
          var valSel1 = $('#dspecies').children("option:selected").text();
          var valSel2 = $(this).children("option:selected").text();
          $.get('/formdrop', {columnname: "cell", selected1: valSel1, selected2: valSel2,table:"targets", where2:"tissue", where1:"species",boxID:"dcell"}, function(data){
            $('#dcell').html(data);
          });
        });
        $('#dlibname').change(function(){
          var valSel = $(this).children("option:selected").text();
          $.get('/formdrop', {columnname: "selection_name", selected1: valSel, table:"selections", where1:"library_name", boxID:"dselname"}, function(data){
            $('#dselname').html(data);
            $('#dselname').prop('selectedIndex', -1);
            $('#ddsname').prop('selectedIndex', -1);
          });
        });
        $('#dselname').change(function(){
          var valSel1 = $('#dlibname').children("option:selected").text();
          var valSel2 = $(this).children("option:selected").text();
          $.get('/formdrop', {columnname: "dataset_name", selected1: valSel1, selected2: valSel2, table:"sequencing_datasets", where1:"library_name", where2:"selection_name",boxID:"dselname"}, function(data){
            $('#ddsname').html(data);
            $('#ddsname').prop('selectedIndex', -1);
          });
        });
        $('#ddsname').change(function(){
          var valSel = $(this).children("option:selected").text();
          $.get('/datalist', {required: "true", selected1: valSel, where1:"dataset_name", columnname: "peptide_sequence", label:"peptide", fieldname:"peptide", listname:"peptidelist", listlabel: "peptides", table:"peptides_sequencing_datasets"}, function(data){
            $('#formpeps').html(data);
          }); 
        });
      });
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
      .jstree( {"themeroller": {"item_leaf": false,
                                "item_clsd": false,
                                "item_open":false  },
                "plugins" : ["html_data",  "themeroller"],})
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
      .jstree( {"plugins" : ["html_data", "ui", "themeroller"],
                "item_leaf": false, })
      .delegate("a", "click", function(event, data){
     } );


  } );

