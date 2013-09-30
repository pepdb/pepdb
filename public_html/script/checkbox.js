pepdb.checkbox = pepdb.checkbox || {};

$(document).ready(function(){
  var formAll = ["#c_all_sel", "#r_all_sel", "#r_all_ds", "#all_sell", "#all_ds"];

    /*(un)check all checkboxes on checking "all"*/
  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        $(this).prop('checked', marked);
      });
    });
  });

  $('#comp-selection input:checkbox').click(function(){
    var checkedSels = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_sel"){
        checkedSels.push(elemVal);
      }
    });
    $('#comp-dataset').load('/radiolist',{checkedElem: checkedSels, radioName:'radio_ds' } );
  });

  $('#ref-selection input:checkbox').click(function(){
    var checkedSels = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_sel"){
        checkedSels.push(elemVal);
      }
    });
    $('#ref-dataset').load('/checklist',{checkedElem: checkedSels, checkName: 'ref_ds[]', allElem: 'r_all_ds', allElemVal: 'all_ds', selector: 'ds', sec: 'r_' }, function(){
      if (!isFirstLoad(pepdb.checkbox, "checkbox.js")){
        return;
      }
      $.getScript("/script/checkbox.js", function(){
        $.getScript("/script/initbutton.js");
      });
    });
  });
  
});
