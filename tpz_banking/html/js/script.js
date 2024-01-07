

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

    if (item.action === 'toggle') {
      item.toggle ? $("#banking").fadeIn() : $("#banking").fadeOut();

      if (item.toggle){
        LoadBackgroundImage('default');

        CurrentPageType == "MAIN";
        
        $('.banking_mainpage').fadeIn();

      }

    } else if (event.data.action == "loadBankingInformation"){
      var prod_client = event.data.client_det;

      $('#banking_account_iban').text(Locales.Iban + prod_client.id)
      $('#banking_account_username').text(prod_client.username);

      $('#banking_account_money_balance').text(prod_client.money);
      $('#banking_account_gold_balance').text(prod_client.gold);

      CurrentAccountIBAN = prod_client.id;

    } else if (event.data.action == "loadBill"){
      var prod_bill = event.data.result;

			$("#billings").append(
				`<div id="billings_main"> </div>` +
        `<div billingId = "` + prod_bill.id + `" class = "billings_label" id="billings_button">` + Locales.PayBillButton + `</div>` +
				`<div class = "billings_label" id="billings_reason">` + prod_bill.reason + `</div>` +
				`<div class = "billings_label" id="billings_issuer">` + prod_bill.issuer + `</div>` +
        `<div class = "billings_label" id="billings_account">` + Locales[prod_bill.account] + `</div>` +
        `<div class = "billings_label" id="billings_cost">` + prod_bill.cost + `</div>` +
        `<div class = "billings_label" id="billings_date">` + prod_bill.date + `</div>`
      );

    } else if (event.data.action == "clearBills"){
      $('#billings').html('');

    } else if (event.data.action == "loadHistoryRecord"){
      var prod_record = event.data.result;

			$("#history_records").append(
				`<div id="history_records_main" ></div>` +
				`<div class = "history_record_label" id="history_records_reason">` + prod_record.reason + `</div>` +
				`<div class = "history_record_label" id="history_records_account">` + Locales[prod_record.account] + `</div>` +
        `<div class = "history_record_label" id="history_records_cost">` + prod_record.cost + `</div>` +
        `<div class = "history_record_label" id="history_records_date">` + prod_record.date + `</div>`
        );
    
    } else if (event.data.action == "sendNotification") {
      var prod_notify = event.data.notification_data;
      sendNotification(prod_notify.message, prod_notify.color);

    } else if (event.data.action == "close") {
      closeBanking();
    }

  });

  $("body").on("keyup", function (key) {
    if (key.which == 27){ 
      CurrentPageType == "MAIN" || CurrentPageType == null ? closeBanking() : OnBackButtonAction();
    } 
  });


  /*-----------------------------------------------------------
  Main Banking Page & Buttons Action
  -----------------------------------------------------------*/

  $("#banking").on("click", "#banking_exit_button", function() {
    playAudio("button_click.wav");
    closeBanking();
  });

  $("#banking").on("click", "#banking_deposit_button", function() {
    CurrentPageClassName = "transactionpage";
    CurrentPageType      = "DEPOSIT";

    $("#banking_transaction_account_title").text(Locales.AccountTitle);
    $("#banking_transaction_title").text(Locales.DepositTitle);
    OnSelectedButtonPageOpen();
  });

  $("#banking").on("click", "#banking_withdraw_button", function() {
    CurrentPageClassName = "transactionpage";
    CurrentPageType      = "WITHDRAW";

    $("#banking_transaction_account_title").text(Locales.AccountTitle);
    $("#banking_transaction_title").text(Locales.WithdrawTitle);
    OnSelectedButtonPageOpen();
  });

  $("#banking").on("click", "#banking_transfer_button", function() {
    CurrentPageClassName = "transactionpage";
    CurrentPageType      = "TRANSFER";

    $("#banking_transaction_account_title").text(Locales.AccountTransferTitle);
    $("#banking_transaction_title").text(Locales.TransferTitle);

    $("#banking_transaction_transfer_fee_footer").text(Locales.TransferVATFooter);

    $("#banking_transaction_previous").hide();
    $("#banking_transaction_current").hide();
    $("#banking_transaction_next").hide();

    $("#banking_transaction_iban_input").show();

    OnSelectedButtonPageOpen();
  });

  $("#banking").on("click", "#banking_billing_button", function() {
    CurrentPageClassName = "billingpage";
    CurrentPageType      = "BILLING";

    OnSelectedButtonPageOpen();

    $('#billings').html('');

    $.post("http://tpz_banking/requestBills", JSON.stringify({ }));

  });

  $("#banking").on("click", "#banking_records_button", function() {
    CurrentPageClassName = "recordspage";
    CurrentPageType      = "RECORDS";

    OnSelectedButtonPageOpen();

    $('#history_records').html('');

    $.post("http://tpz_banking/requestTransactionRecords", JSON.stringify({ }));
  });

  function OnSelectedButtonPageOpen(){
    playAudio("button_click.wav");

    LoadBackgroundImage('default_empty');
    
    $('.banking_mainpage').fadeOut();
    $(".banking_" + CurrentPageClassName).fadeIn();
  }

  /*-----------------------------------------------------------
   Back Button Actions
  -----------------------------------------------------------*/

  $("#banking").on("click", "#banking_transaction_back_button", function() {
    OnBackButtonAction();
  });

  $("#banking").on("click", "#banking_billingpage_back_button", function() {
    OnBackButtonAction();
  });

  $("#banking").on("click", "#banking_recordspage_back_button", function() {
    OnBackButtonAction();
  });

  function OnBackButtonAction(){
    playAudio("button_click.wav");

    LoadBackgroundImage('default');

    $('.banking_' + CurrentPageClassName).fadeOut();
    $('.banking_mainpage').fadeIn();

    $('#banking_transaction_amount_input').val(1);
    $("#banking_transaction_current").text(Locales[0]);

    CurrentPageClassName = "mainpage";
    CurrentPageType      = "MAIN";
    CurrentAccountType   = 0;
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

    CurrentAccountType--;

    if (CurrentAccountType <= 0){
      CurrentAccountType = 0;
    }

    $("#banking_transaction_current").text(Locales[CurrentAccountType]);

  });


  $("#banking").on("click", "#banking_transaction_next", function() {
    playAudio("button_click.wav");

    CurrentAccountType++;

    if (CurrentAccountType >= 1){
      CurrentAccountType = 1;
    }

    $("#banking_transaction_current").text(Locales[CurrentAccountType]);
  });


  /*-----------------------------------------------------------
  Deposit Banking Page & Buttons Action
  -----------------------------------------------------------*/

  $("#banking").on("click", "#banking_transaction_accept_button", function() {
    playAudio("button_click.wav");

    var inputAmount = $('#banking_transaction_amount_input').val();

    if (CurrentPageType == "DEPOSIT" ) {

      $.post("http://tpz_banking/requestAccountDeposit", JSON.stringify({ 
        account : CurrentAccountType,
        amount : inputAmount,
      }));

      $('#banking_transaction_amount_input').val(1);

    }else if (CurrentPageType == "WITHDRAW" ) {
      $.post("http://tpz_banking/requestAccountWithdrawal", JSON.stringify({ 
        account : CurrentAccountType,
        amount : inputAmount,
      }));

      $('#banking_transaction_amount_input').val(1);

    }else if (CurrentPageType == "TRANSFER" ) {
      var iban = $('#banking_transaction_iban_input').val();

      $.post("http://tpz_banking/requestAccountTransfer", JSON.stringify({ 
        account : 0,
        currentIban : CurrentAccountIBAN,
        iban : iban,
        amount : inputAmount,
      }));

      $('#banking_transaction_iban_input').val(null);
      $('#banking_transaction_amount_input').val(1);
    }

  });


  /*-----------------------------------------------------------
  Transfer Banking Page & Buttons Action
  -----------------------------------------------------------*/
  
  $("#banking").on("click", "#banking_transferpage_accept_button", function() {
    playAudio("button_click.wav");

    var accountDropDown = document.getElementById("banking_t_account_select");
    var accountType =  accountDropDown.options[accountDropDown.selectedIndex].text;

    var accountBankDropDown = document.getElementById("banking_bank_select");
    var accountBank =  accountBankDropDown.options[accountBankDropDown.selectedIndex].text;

    var inputAmount = document.getElementById('banking_transfer_amount_input').value;

    $.post("http://tpz_banking/requestAccountTransfer", JSON.stringify({ 
      bank : accountBank,
      type : accountType,
      amount : inputAmount,
    }));

    document.getElementById('banking_transfer_amount_input').value = 1;
  });


  /*-----------------------------------------------------------
  Billing Actions
  -----------------------------------------------------------*/

  $("#banking").on("click", "#billings_button", function() {
    playAudio("button_click.wav");

    var $button    = $(this);
    var $billingId = $button.attr('billingId');

    $.post("http://tpz_banking/payBill", JSON.stringify({ 
      billingId : $billingId,
    }));

  });


});

