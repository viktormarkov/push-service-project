document.addEventListener('DOMContentLoaded', () => {
  const cityElement = document.querySelector('.city-block')
  const roleElement = document.querySelector('#user_role')
  setCityBlockVisibility(cityElement, roleElement.value)
  roleElement.addEventListener("change", function() {
    setCityBlockVisibility(cityElement, roleElement.value)
  });
});

function setCityBlockVisibility(cityElement, roleValue) {
  if (roleValue=== 'admin') {
    cityElement.classList.add('display-none')
    cityElement.classList.remove('display-block')
  } else {
    cityElement.classList.add('display-block')
    cityElement.classList.remove('display-none')
  }
}