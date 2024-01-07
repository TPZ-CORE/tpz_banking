
var CurrentPageClassName = null;
var CurrentPageType      = null;
var CurrentAccountType   = 0;
var CurrentAccountIBAN   = 0;

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ${FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 

  $("#banking").hide();

  displayPage("banking_mainpage", "visible");
  $(".banking_mainpage").fadeOut();

  displayPage("banking_transactionpage", "visible");
  $(".banking_transactionpage").fadeOut();

  displayPage("banking_billingpage", "visible");
  $(".banking_billingpage").fadeOut();

  displayPage("banking_recordspage", "visible");
  $(".banking_recordspage").fadeOut();

  displayPage("notification", "visible");
  $("#notification_message").fadeOut();

  $("#banking_transaction_iban_input").hide();

  $('#banking_deposit_button').text(Locales.Deposit);
  $('#banking_withdraw_button').text(Locales.Withdraw);
  $('#banking_transfer_button').text(Locales.Transfer);
  $('#banking_billing_button').text(Locales.Billing);
  $('#banking_records_button').text(Locales.Records);
  $('#banking_exit_button').text(Locales.Exit);

  $("#banking_transaction_accept_button").text(Locales.Accept);
  $("#banking_transaction_back_button").text(Locales.Back);

  $("#banking_billingpage_back_button").text(Locales.Back);
  $("#banking_recordspage_back_button").text(Locales.Back);

  $("#banking_billingpage_action").text(Locales.ActionTitle);
  $("#banking_billingpage_reason").text(Locales.ReasonTitle);
  $("#banking_billingpage_issuer").text(Locales.IssuerTitle);
  $("#banking_billingpage_account").text(Locales.AccountTitle);
  $("#banking_billingpage_cost").text(Locales.CostTitle);
  $("#banking_billingpage_date").text(Locales.DateTitle);

  $("#banking_recordspage_reason").text(Locales.ReasonTitle);
  $("#banking_recordspage_account").text(Locales.AccountTitle);
  $("#banking_recordspage_cost").text(Locales.CostTitle);
  $("#banking_recordspage_date").text(Locales.DateTitle);

  $("#banking_transaction_current").text(Locales[0]);

}) .catch( err => { console.error(err); });


function playAudio(sound) {
	var audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

function sendNotification(text, color, cooldown){

  cooldown = cooldown == cooldown == null || cooldown == 0 || cooldown === undefined ? 4000 : cooldown;

  $("#notification_message").text(text);
  $("#notification_message").css("color", color);
  $("#notification_message").fadeIn();

  setTimeout(function() { $("#notification_message").text(""); $("#notification_message").fadeOut(); }, cooldown);
}

function load(src) {
  return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', resolve);
      image.addEventListener('error', reject);
      image.src = src;
  });
}

function randomIntFromInterval(min, max) { // min and max included 
  return Math.floor(Math.random() * (max - min + 1) + min)
}

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function onNumbers(evt){
  // Only ASCII character in that range allowed
  var ASCIICode = (evt.which) ? evt.which : evt.keyCode;
  
  if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57))
      return false;
  return true;
}

function LoadBackgroundImage(imageUrl) {
  const image = 'img/' + imageUrl + '.png';
  load(image).then(() => {
    document.getElementById("banking").style.backgroundImage = `url(${image})`;
  });
}

function closeBanking() {
  $('#banking').fadeOut();

  $(".banking_mainpage").fadeOut();
  $(".banking_transactionpage").fadeOut();

  $(".banking_billingpage").fadeOut();
  $(".banking_recordspage").fadeOut();

  CurrentPageClassName = null;
  CurrentPageType      = null;
  CurrentAccountType   = 0;

  $('#banking_transaction_amount_input').val(1);
  $("#banking_transaction_current").text(Locales[0]);

  $('#history_records').html('');
  $('#billings').html('');

  $("#banking_transaction_transfer_fee_footer").text("");
  $("#banking_transaction_iban_input").hide();

	$.post('http://tpz_banking/close', JSON.stringify({}));
}
