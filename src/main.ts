import './style.css';

interface ViewCountResponse {
  views: string;
}

const viewCount = document.getElementById('count')!;

async function getViewCount() {
  try {
    const response = await fetch(
      'https://ynrwjfdti5fzjemn7yxl3cmqkm0ruvnd.lambda-url.us-east-2.on.aws/'
    );
    const data: ViewCountResponse = await response.json();
    const views = data.views;
    viewCount.innerText = views;
  } catch (error) {
    console.log(window.location.hostname);
    const isLocal = window.location.hostname === 'localhost';
    if (isLocal) {
      viewCount.innerText = 'Disabled locally';
      return;
    }
    console.error(error);
    viewCount.style.display = 'none';
  }
}

getViewCount();
