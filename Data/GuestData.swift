import Foundation

// MARK: - Guest Mode Data
struct GuestData {
    static let vocabulary: [(String, String)] = [
        ("accomplish", "성취하다, 완수하다"),
        ("adequate", "적절한, 충분한"),
        ("analyze", "분석하다"),
        ("approach", "접근하다, 방법"),
        ("assess", "평가하다"),
        ("benefit", "이익, 혜택"),
        ("category", "범주, 분류"),
        ("challenge", "도전, 어려움"),
        ("concept", "개념"),
        ("consequence", "결과, 영향"),
        ("contribute", "기여하다"),
        ("crucial", "중요한, 결정적인"),
        ("demonstrate", "보여주다, 증명하다"),
        ("determine", "결정하다, 판단하다"),
        ("develop", "개발하다, 발전시키다"),
        ("distinguish", "구별하다"),
        ("efficient", "효율적인"),
        ("emphasize", "강조하다"),
        ("establish", "설립하다, 확립하다"),
        ("evaluate", "평가하다"),
        ("evidence", "증거"),
        ("expand", "확장하다"),
        ("factor", "요인"),
        ("function", "기능, 작동하다"),
        ("generate", "생성하다"),
        ("identify", "식별하다"),
        ("implement", "실행하다"),
        ("indicate", "나타내다"),
        ("influence", "영향을 주다"),
        ("interpret", "해석하다"),
        ("investigate", "조사하다"),
        ("maintain", "유지하다"),
        ("method", "방법"),
        ("modify", "수정하다"),
        ("obtain", "얻다"),
        ("occur", "발생하다"),
        ("participate", "참여하다"),
        ("perspective", "관점"),
        ("potential", "잠재적인"),
        ("previous", "이전의"),
        ("principle", "원칙"),
        ("procedure", "절차"),
        ("process", "과정, 처리하다"),
        ("require", "필요로 하다"),
        ("research", "연구"),
        ("resource", "자원"),
        ("respond", "응답하다"),
        ("significant", "중요한"),
        ("strategy", "전략"),
        ("structure", "구조")
    ]
    
    static func createGuestSubject() -> Subject {
        Subject(
            userId: "guest",
            name: "중급 영단어",
            description: "게스트 모드 체험용 중급 영단어 50개"
        )
    }
    
    static func createGuestFlashcards(subjectId: String) -> [Flashcard] {
        vocabulary.map { word, meaning in
            Flashcard(
                userId: "guest",
                subjectId: subjectId,
                front: word,
                back: meaning
            )
        }
    }
} 