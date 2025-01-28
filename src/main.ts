import './style.css';

interface ViewCountResponse {
  views: string;
}

const viewCount = document.getElementById('count')!;

async function getViewCount() {
  const isLocal = window.location.hostname === 'localhost';
  if (isLocal) {
    viewCount.innerText = 'Disabled locally';
    return;
  }

  try {
    // TODO: don't hardcode the URL
    const response = await fetch(
      'https://2vjgoz7839.execute-api.us-east-1.amazonaws.com/serverless_lambda_stage/view-counter'
    );

    // TODO: if no items in the table, create one (id: 0, views: 0)
    const data: ViewCountResponse = await response.json();
    const views = data.views;
    viewCount.innerText = views;
  } catch (error) {
    console.error(error);
    viewCount.style.display = 'none';
  }
}

getViewCount();
