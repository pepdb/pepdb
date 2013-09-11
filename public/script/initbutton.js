pepdb.initbutton = pepdb.initbutton || {};

$(document).ready(function(){
  if(!isFirstLoad(pepdb.initbutton, "initbutton.js")){
    return;
  }
  
  $('#compare').click(function(){
    var checkedRef = [];
    var comMaxDom = $('#comp_dom_max').val();
    var comMinDom = $('#comp_dom_min').val();
    var reMaxDom = $('#ref_dom_max').val();
    var reMinDom = $('#ref_dom_min').val();
    var checkedDS = $('#comp-dataset input:radio:checked').attr('value');
    var compRadio = $('#comp-buttons input:radio:checked').attr('id');
    $('#ref-dataset input:checkbox:checked').each(function(){
      var elemVal = this.value;
      if(elemVal != "all_ds"){
        checkedRef.push(elemVal);
      }
    });
     //getScript für geladene table
    $('#results').load('/peptide_results', {compRef: checkedRef , compDS: checkedDS, compType: compRadio, dsMaxDom: comMaxDom, dsMinDom: comMinDom, rMaxDom: reMaxDom, rMinDom: reMinDom});
  });
});
