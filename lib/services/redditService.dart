
import 'package:draw/draw.dart';

class RedditService {

  static Reddit reddit;

  static List<Submission> getSubmissions(List<UserContent> userContens) {
    List<Submission> submissions = <Submission>[];
    userContens.forEach((userContent) {
      bool isSubmission = userContent is Submission;
      if(isSubmission) {
        submissions.add(userContent as Submission);
      }
    });
    return submissions;
  }

}
