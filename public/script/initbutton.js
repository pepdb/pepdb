$(document).ready(function(){
  $('#compare').click(function(){
    var checked_ref = [];
    var comMaxDom = $('#comp_dom_max').val();
    var comMinDom = $('#comp_dom_min').val();
    var reMaxDom = $('#ref_dom_max').val();
    var reMinDom = $('#ref_dom_min').val();
    var checked_radio = $('#comp-dataset input:radio:checked').attr('value');
    alert(cMaxDom); 
    $('#ref-dataset input:checkbox:checked').each(function(){
      var elemVal = this.value;
      if(elemVal != "all_ds"){
        checked_ref.push(elemVal);
      }
    });
     //getScript für geladene table
    $('#results').load('/peptide_result', {checkRef: checked_ref, checkCom: checked_radio, cMaxDom: comMaxDom, cMinDom: comMinDom, rMaxDom: reMaxDom, rMinDom; reMinDom})
  });

});
