

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

    if (item.action === 'toggle') {
      item.toggle ? $("#banking").fadeIn() : $("#banking").fadeOut();

      if (item.toggle){

        TRANSACTION_ACTION_TYPE = "MAIN";
        TRANSACTION_DEFAULT_TRANSFER      = item.transfer_transaction_fees;


        // We hide the BACK TO MAIN ACCOUNT since the player when opening the Bank is already on MAIN.
        $("#banking_account_page_back_to_main_button").hide();

        if (!item.has_account){

          TRANSACTION_ACTION_TYPE = "MAIN";

          let $description = Locales['ACCOUNT_REGISTER_DESCRIPTION'].replace('<cost>', item.account_cost);
          $("#banking_account_create_page_description").text($description);

          $('.banking_account_create_page').fadeIn();

        }else{

          $('.banking_mainpage').fadeIn();
        }
      
      }

    } else if (event.data.action == 'loadAccount'){

      TRANSACTION_ACTION_TYPE = "MAIN";
      CURRENT_IBAN            = event.data.iban;
      LOGGED_IN_ACCOUNT_TYPE  = event.data.account_type;

      $(".banking_account_page").fadeOut();

      $('.banking_mainpage').fadeIn();

    } else if (event.data.action == 'registeredAccount') {

      $('.banking_account_create_page').hide();

      $('.banking_mainpage').fadeIn();

    } else if (event.data.action == "loadBankingInformation"){
      var prod_client = event.data.client_det;

      $('#banking_account_iban').text(Locales['IBAN'] + prod_client.iban)

      $('#banking_account_money_balance').text(prod_client.cash);
      $('#banking_account_gold_balance').text(prod_client.gold);

      CURRENT_IBAN = prod_client.iban;

    } else if (event.data.action == "sendNotification") {
      var prod_notify = event.data.notification_data;
      sendNotification(prod_notify.message, prod_notify.color);

    } else if (event.data.action == "close") {
      closeBanking();
    }

  });


  /* REGISTRATION */

  $("#banking").on("click", "#banking_account_create_page_button", function() {
    playAudio("button_click.wav");
    $.post("http://tpz_banking/register", JSON.stringify({ }));
  });

  
  $("#banking").on("click", "#banking_account_create_page_exit_button", function() {
    playAudio("button_click.wav");
    closeBanking();
  });

  /*
    MAIN PAGE ACTIONS
  */

  // The specified button is used for closing the NUI.
  $("#banking").on("click", "#banking_exit_button", function() {
    playAudio("button_click.wav");
    closeBanking();
  });


  /*
    TRANSACTIONS
  */

  $("#banking").on("click", "#banking_deposit_options_page", function() {
    TRANSACTION_CLASS_TYPE  = "transactions_action_page"; TRANSACTION_ACTION_TYPE = "DEPOSIT";

    // Action Texts
    $("#banking_transaction_input_title").text(Locales['TRANSACTIONS_DESC_AMOUNT_TO_DEPOSIT']);

    // reset
    SELECTED_ACCOUNT_TYPE = 0;
    $("#banking_transaction_current").text(Locales[0]);
    $("#banking_transaction_amount_input").val(1);

    $("#banking_transactions_fees_description_action_page").text(Locales['TRANSACTIONS_DESC_FEE'].replace('<fee>', 0));

    OnSelectedButtonPageOpen(false);
  });

  $("#banking").on("click", "#banking_withdraw_options_page", function() {
    TRANSACTION_CLASS_TYPE  = "transactions_action_page"; TRANSACTION_ACTION_TYPE = "WITHDRAW";

    // Action Texts
    $("#banking_transaction_input_title").text(Locales['TRANSACTIONS_DESC_AMOUNT_TO_WITHDRAW']);

    // reset
    SELECTED_ACCOUNT_TYPE = 0;
    $("#banking_transaction_current").text(Locales[0]);
    $("#banking_transaction_amount_input").val(1);

    $("#banking_transactions_fees_description_action_page").text(Locales['TRANSACTIONS_DESC_FEE'].replace('<fee>', 0));

    OnSelectedButtonPageOpen(false);
  });

  $("#banking").on("click", "#banking_transfer_options_page", function() {
    TRANSACTION_CLASS_TYPE = "transactions_action_page"; TRANSACTION_ACTION_TYPE = "TRANSFER";

    // Action Texts
    $("#banking_transaction_input_title").text(Locales['TRANSACTIONS_DESC_AMOUNT_TO_TRANSFER']);
    
    // reset
    SELECTED_ACCOUNT_TYPE = 0;
    $("#banking_transaction_current").text(Locales[0]);
    $("#banking_transaction_amount_input").val(1);

    $("#banking_transactions_fees_description_action_page").text(Locales['TRANSACTIONS_DESC_FEE'].replace('<fee>', TRANSACTION_DEFAULT_TRANSFER));

    $("#banking_transaction_previous").hide();
    $("#banking_transaction_current").hide();
    $("#banking_transaction_next").hide();

    $("#banking_transaction_iban_input").val('');
    $("#banking_transaction_iban_input").show();

    OnSelectedButtonPageOpen(false);
  });

  // The specified button is going back to the transaction options page.
  $("#banking").on("click", "#banking_transactions_back_action_page", function() {
    playAudio("button_click.wav");

    $(".banking_" + TRANSACTION_CLASS_TYPE).fadeOut();

    TRANSACTION_CLASS_TYPE  = "mainpage";
    TRANSACTION_ACTION_TYPE = "MAIN";

    /* The following elements are from Transactions Actions Page. Those elements are getting reset because deposit, withdraw between transfer and transactions history,
       have element differences.
    */

    $("#banking_transaction_iban_input").hide();

    $("#banking_transaction_previous").show();
    $("#banking_transaction_current").show();
    $("#banking_transaction_next").show();

    $(".banking_" + TRANSACTION_CLASS_TYPE).fadeIn();

  });


  /*-----------------------------------------------------------
   Back Button Actions
  -----------------------------------------------------------*/

  function OnBackButtonAction(){
    playAudio("button_click.wav");

    $('.banking_' + TRANSACTION_CLASS_TYPE).fadeOut();
    $('.banking_mainpage').fadeIn();

    $('#banking_transaction_amount_input').val(1);
    $("#banking_transaction_current").text(Locales[0]);

    TRANSACTION_CLASS_TYPE  = "mainpage";
    TRANSACTION_ACTION_TYPE = "MAIN";
    SELECTED_ACCOUNT_TYPE   = 0;

    $("#banking_transaction_transfer_fee_footer").text("");

    $("#banking_transaction_previous").show();
    $("#banking_transaction_current").show();
    $("#banking_transaction_next").show();

    $("#banking_transaction_iban_input").hide();

    $('#banking_transaction_iban_input').val(null);
  }

  /*-----------------------------------------------------------
  Currency Account Button Actions
  -----------------------------------------------------------*/

  $("#banking").on("click", "#banking_transaction_previous", function() {
    playAudio("button_click.wav");

    SELECTED_ACCOUNT_TYPE--;

    if (SELECTED_ACCOUNT_TYPE <= 0){
      SELECTED_ACCOUNT_TYPE = 0;
    }

    $("#banking_transaction_current").text(Locales[SELECTED_ACCOUNT_TYPE]);

    let feeDescription = 0;

    if (TRANSACTION_ACTION_TYPE == 'TRANSFER') {
      feeDescription = TRANSACTION_DEFAULT_TRANSFER;
    }

    $("#banking_transactions_fees_description_action_page").text(Locales['TRANSACTIONS_DESC_FEE'].replace('<fee>', feeDescription));

  });


  $("#banking").on("click", "#banking_transaction_next", function() {
    playAudio("button_click.wav");

    SELECTED_ACCOUNT_TYPE++;

    if (SELECTED_ACCOUNT_TYPE >= 1){
      SELECTED_ACCOUNT_TYPE = 1;
    }

    $("#banking_transaction_current").text(Locales[SELECTED_ACCOUNT_TYPE]);

    let feeDescription = 0;

    if (TRANSACTION_ACTION_TYPE == 'TRANSFER') {
      feeDescription = TRANSACTION_DEFAULT_TRANSFER;
    }

    $("#banking_transactions_fees_description_action_page").text(Locales['TRANSACTIONS_DESC_FEE'].replace('<fee>', feeDescription));

  });


  /*-----------------------------------------------------------
  Deposit Banking Page & Buttons Action
  -----------------------------------------------------------*/

  $("#banking").on("click", "#banking_transaction_accept_button", function() {
    playAudio("button_click.wav");

    var inputAmount = $('#banking_transaction_amount_input').val();

    if (TRANSACTION_ACTION_TYPE == "DEPOSIT" ) {

      $.post("http://tpz_banking/executeTransactionType", JSON.stringify({ 
        iban    : CURRENT_IBAN,
        type    : 'DEPOSIT',
        account : SELECTED_ACCOUNT_TYPE,
        amount  : inputAmount,
      }));

      $('#banking_transaction_amount_input').val(1);

    }else if (TRANSACTION_ACTION_TYPE == "WITHDRAW" ) {

      $.post("http://tpz_banking/executeTransactionType", JSON.stringify({ 
        iban    : CURRENT_IBAN,
        type    : 'WITHDRAW',
        account : SELECTED_ACCOUNT_TYPE,
        amount : inputAmount,
      }));

      $('#banking_transaction_amount_input').val(1);

    }else if (TRANSACTION_ACTION_TYPE == "TRANSFER" ) {
      var iban = $('#banking_transaction_iban_input').val();

      $.post("http://tpz_banking/executeTransactionType", JSON.stringify({ 
        iban    : CURRENT_IBAN,
        type    : 'TRANSFER',
        account : 0,
        to_iban : iban,
        amount  : inputAmount,
      }));

      //$('#banking_transaction_iban_input').val(null);
      $('#banking_transaction_amount_input').val(1);
    }

  });

  function OnSelectedButtonPageOpen(cb){
    playAudio("button_click.wav");

    $('.banking_mainpage').fadeOut();
    $('.banking_transaction_options_page').fadeOut();

    // delay?
    $(".banking_" + TRANSACTION_CLASS_TYPE).fadeIn();
  }


});

