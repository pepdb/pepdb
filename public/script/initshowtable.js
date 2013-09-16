$(document).ready(function(){
/* initialize second table with searchable columns*/
  var qTable = $('#show_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
  });
  $('#show_table thead input').keyup( function(){
    qTable.fnFilter(this.value, $("#show_table thead input").index(this));
  });

  $('#show_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('#show_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "";
      this.value = "";
    }
  } );

  $('#show_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      this.className = "search_init";
      this.value = asInitVals[$("#show_table thead input").index(this)];
    }
  } );

  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#show_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
   // var first_choice =  $('#select_table').data('first-choice');
    if (route == "/comp-search"){
      $('#infos').load('/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == "/cluster-search"){
      if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#clprop').load('/cluster-infos', {selCl: selectedID}, function(){
        $.getScript('/script/tableinit.js', function(){
          $('#clsearch').toggle();
        });
        
      });
    } else {
      $.get('/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript('/script/initbutton.js');
      });
    }     
  })
});
