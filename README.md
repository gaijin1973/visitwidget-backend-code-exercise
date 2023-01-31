# Visit Widget Backend Code Exercise

## About

A simple backend based on the [Rails Getting Started Guide](https://guides.rubyonrails.org/getting_started.html).
It is a REST backend only, returning JSON and accepting JSON for updates/creates. Below are steps to get the code
up and running, and then directions on completing the exercise by adding certain actions. It is estimated that
the code exercise will take 2-4 hours, and there will be follow up questions and discussion of the submission at
the subsequent technical interview.

## Getting Started

1. Clone the repository.
2. From root, run `bundle install`
3. From root, run `rake db:migrate`
4. From root, run `rake db:seed`

## Exercise

Look for `TODO: ` in the code for inline comments, or here is a unified list:

1. Add endpoints for updating and deleting an Article in `articles_controller.rb`
2. Fill in the endpoint in the `articles_controller.rb` to allow an import of Articles with Comments. See `import.json` for an example json payload the endpoint should accept.
3. Add pagination and filtering to the list endpoint in `articles_controller.rb`. Should be able to filter on `status` equaling one of the 3 statuses and `title` or `body` containing a string.
4. Add tests for `articles_controller.rb` in `articles_controller_test.rb`. (please ignore `comments_controller_test.rb`)

## Submission

Once complete, please respond to the email in which you received this code exercise with either a zip of all the code or a url of a fork that is publicly accessible.
We will test and run the code, and followup with next steps. Thank you!
