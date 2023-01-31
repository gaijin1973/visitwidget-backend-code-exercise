

articles_data = [
  {
    title: "This One Weird Trick",
    body: "Doctors hate him, never pay for prescriptions again.",
    status: "public",
    comments: [{
      body: "This is pretty bogus.",
      status: "public",
      commenter: "Willy"
    }]
  },
  {
    title: "Doge Coin",
    body: "Make millions while you sleep by investing in crypto!",
    status: "public",
    comments: [{
      body: "Such a cute little doggy.",
      status: "public",
      commenter: "Meghan"
    }]
  },
  {
    title: "First World Problems",
    body: "Having a runny nose is considered to be the biggest first world problem, new research has revealed.",
    status: "archived",
    comments: [{
      body: "Allergies are a symptom of a weakened immunity.",
      status: "public",
      commenter: "Harry"
    }]
  },
]

articles_data.each { |article_data|
  article = Article.create!(title: article_data[:title], body: article_data[:body], status: article_data[:status])
  article_data[:comments].each { |comment_data|
    Comment.create!(body: comment_data[:body], status: comment_data[:status], commenter: comment_data[:commenter], article: article)
  }
}