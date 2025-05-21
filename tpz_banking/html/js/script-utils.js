
var TRANSACTION_CLASS_TYPE            = null;
var TRANSACTION_ACTION_TYPE           = "MAIN";
var SELECTED_ACCOUNT_TYPE             = 0;
var CURRENT_IBAN                      = null;

let TRANSACTION_DEFAULT_TRANSFER      = 0;

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

  displayPage("banking_account_create_page", "visible");
  $(".banking_account_create_page").fadeOut();

  displayPage("banking_mainpage", "visible");
  $(".banking_mainpage").fadeOut();

  displayPage("banking_transactions_action_page", "visible");
  $(".banking_transactions_action_page").fadeOut();

  displayPage("notification", "visible");
  $("#notification_message").fadeOut();

  $("#banking_transaction_iban_input").hide();

  $('#banking_exit_button').text(Locales['EXIT']);

  $("#banking_account_create_page_title").text(Locales['ACCOUNT_REGISTER_TITLE']);
  $("#banking_account_create_page_button").text(Locales['ACCOUNT_REGISTER_BUTTON']);
  $("#banking_account_create_page_exit_button").text(Locales['EXIT']);

  /* Transaction Options Page */
  $("#banking_deposit_options_page").text(Locales['TRANSACTIONS_BUTTON_DEPOSIT']);
  $("#banking_withdraw_options_page").text(Locales['TRANSACTIONS_BUTTON_WITHDRAW']);
  $("#banking_transfer_options_page").text(Locales['TRANSACTIONS_BUTTON_TRANSFER']);

  $("#banking_transaction_accept_button").text(Locales['ACCEPT']);
  $("#banking_transactions_back_action_page").text(Locales['BACK']);

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

function closeBanking() {
  $('#banking').fadeOut();

  $(".banking_account_create_page").fadeOut();
  $(".banking_mainpage").fadeOut();

  $(".banking_transactions_action_page").fadeOut();

  SELECTED_ACCOUNT_TYPE   = 0;

  $('#banking_transaction_amount_input').val(1);
  $("#banking_transaction_current").text(Locales[0]);

  $("#banking_transaction_transfer_fee_footer").text("");
  $("#banking_transaction_iban_input").hide();

	$.post('http://tpz_banking/close', JSON.stringify({}));
}
