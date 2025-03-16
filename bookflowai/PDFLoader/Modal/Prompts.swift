import Foundation

enum Constants {
    static let geminiPrompt = """
                    You are an experienced specialist in PDF document processing. Your task is to analyze the table of contents of any book and return the data in JSON format strictly adhering to the exact page numbers provided in the input, without any modifications.
    
                    Analysis Instructions:
                        1. Text Analysis:
                        Carefully examine the content of a given PDF page to identify the table of contents (TOC). Detect structural elements such as chapters, exercises, subsections, and special sections (e.g., introductions, appendices). The TOC input will be provided as a list of lines in the format "[page number]. [title]" (e.g., "141. Ejercicios U1"), where the page number is the precise, unadjusted, and final page number as it appears in the book’s table of contents. You must treat the page number preceding each title as the absolute, authoritative page number for that entry, without any interpretation, adjustment, or transformation.
    
                        2. Defining Boundaries:
                        Based on the text analysis, determine the boundaries of chapters and their associated subsections (e.g., exercises, activities). Group related items together:
                        • Chapters: Primary sections indicated by prominent numbering (e.g., "1", "I", "A", "Chapter 1") or titles without indentation.
                        • Subsections/Exercises: Secondary items linked to chapters, identified by:
                            • Naming patterns (e.g., "Ejercicios U1" relates to "Unidad 1", "Exercises Chapter 1" to "Chapter 1").
                            • Numbering hierarchy (e.g., "1.1" under "1").
                            • Contextual keywords (e.g., "Exercises", "Activities", "Problems").
                            • TOC layout (e.g., indentation or proximity).
                        • Special Sections: Standalone sections (e.g., "Introduction", "Appendix", "Gramática") not tied to a chapter, often at the beginning or end of the TOC.
                        • Recognize numbering styles:
                            • Numeric (e.g., "1", "2", "1.1", "1.2")
                            • Roman numerals (e.g., "I", "II", "III")
                            • Letters (e.g., "A", "B", "a", "b")
                            • Descriptive titles without numbers (e.g., "Introduction")
    
                        3. Rules for Determining Pages:
                           3. Rules for Determining Pages:
                              • Start page (begin_page): For each chapter, subsection, or special section (excluding subsections/exercises within related_exercises), use the exact numeric page number preceding the title in the TOC input, then add 1 to this number to derive the final `begin_page` (e.g., "11. Unidad 0" → `begin_page: 12`, "15. Unidad 1" → `begin_page: 16`). For subsections/exercises within related_exercises, use the exact numeric page numbers as they appear in the TOC input line for that subsection (e.g., "141. Ejercicios U1" → `begin_page: 141`, "148. Ejercicios U2" → `begin_page: 148`). You must not add, subtract, modify, offset, or apply any transformations to the page numbers for subsections/exercises within related_exercises, even if the numbers appear inconsistent with the parent chapter’s range or document structure—these are independent, authoritative ranges as explicitly specified in the input, and you must use them verbatim.
                              • End page (end_page):
                                • If there is a next chapter, subsection, or section in the TOC (excluding subsections/exercises within related_exercises), **end_page = (begin_page of the next item - 1) + 1**, ensuring the final `end_page` is adjusted by +1 (e.g., if the next item’s begin_page is 15, end_page = 15 - 1 + 1 = 15). For subsections/exercises within related_exercises, **end_page = begin_page of the next exercise or section - 1**, using the exact numbers from the input without any adjustments.
                                • If this is the last item in the TOC (for any section type, including exercises), **end_page = null**.
                                • Calculate end_page dynamically based on the next item’s begin_page, using only the exact numbers (with the +1 adjustment for chapters, subsections, and special sections, but not for exercises) from the input, without any other modifications or reinterpretations.
                              • For subsections/exercises within related_exercises: The `begin_page` and `end_page` must be the exact numeric page numbers as they appear in the TOC input line for that subsection (e.g., "141. Ejercicios U1" → `begin_page: 141`, "148. Ejercicios U2" → `begin_page: 148`). You must not add, subtract, modify, offset, or apply any transformations, even if the numbers appear inconsistent with the parent chapter’s range or document structure—these are independent, authoritative ranges as explicitly specified in the input, and you must use them verbatim.
                        4. JSON Format:
                        {
                            "contains_toc": true,
                            "sections": [
                                {
                                    "type": "unit",
                                    "unit_number": "Numeric Chapter Number",
                                    "begin_page": Chapter Start Page Number,
                                    "end_page": Chapter End Page Number,
                                    "name": "Chapter Title",
                                    "related_exercises": [
                                        {
                                            "exercise_name": "Subsection/Exercise Title Without Page Number",
                                            "begin_page": Subsection Start Page Number,
                                            "end_page": Subsection End Page Number
                                        }
                                    ]
                                },
                                {
                                    "type": "special",
                                    "unit_number": "Numeric Special Section Number",
                                    "begin_page": Special Section Start Page Number,
                                    "end_page": Special Section End Page Number,
                                    "name": "Special Section Title",
                                    "related_exercises": []
                                }
                            ]
                        }
    
                        5. Rules for unit_number:
                        • For chapters: Extract the numeric portion from the title or numbering as a string (e.g., "Unidad 1" → "1", "Chapter 2" → "2"). If no number exists, assign sequentially starting from "0" for the first unnumbered chapter.
                        • For special sections: Assign a sequential numeric string starting from the next available number after the last chapter (e.g., if chapters end at "9", special sections start at "10").
                        • Increment `unit_number` based on TOC order, ensuring all values are numeric strings ("0", "1", "2", …).
                        • Subsections/exercises do not have their own unit_number; they are grouped under the parent chapter’s unit_number in `related_exercises`.
                        • Never use null for unit_number.
    
                        6. Processing Rules:
                        • Identify chapter-subsection relationships by:
                            • Matching numbers in titles (e.g., "Unidad 1" and "Ejercicios U1" share "1").
                            • Keywords indicating exercises (e.g., "Ejercicios", "Exercises", "Activities").
                            • TOC hierarchy or indentation.
                        • Group subsections under their corresponding chapter in `related_exercises`.
                        • Assign `unit_number` to chapters based on their extracted number (or sequential if unnumbered), and to special sections sequentially after chapters.
                        • Sort chapters by their extracted numeric order (e.g., "0", "1", "2"), and place special sections at the end with continuing numeric sequence.
                        • Retain chapter and special section titles in their original form from the TOC, optionally prefixed with page numbers if present in the TOC.
                        • For `exercise_name` in `related_exercises`, use the original subsection title without including its page number (e.g., "Ejercicios U1" instead of "142. Ejercicios U1").
                        • Use only numbers for pages, as provided in the TOC input.
                        • Do not add additional fields to the JSON.
    
                        7. If the page does not contain a table of contents:
                        {
                          "contains_toc": false,
                          "sections": []
                        }
    
                        8. Output Requirements:
                           Respond with a valid JSON object only. No additional text, explanations, or formatting outside of a valid JSON structure. Ensure correct sequential assignment of `unit_number`, proper calculation of end pages, accurate grouping of subsections under chapters, and adherence to TOC order with special sections at the end. The response must start and end with curly braces `{}`.
    """
    
    static let geminiImagePrompt = """
                    You are an experienced specialist in PDF document processing. Your task is to analyze the table of contents of any book and return the data in JSON format.
                    
                    Analysis Instructions:
                        1.    Characteristics of a Table of Contents:
                        •    Presence of a list of sections/chapters
                        •    Page numbering (any format)
                        •    Hierarchical structure (chapters, subchapters)
                        •    Text formatting (indentation, alignment)
                        2.    Chapter Structure Variants:
                        •    Numeric numbering (1, 2, 3 or 1.1, 1.2, etc.)
                        •    Roman numerals (I, II, III, IV)
                        •    Letter-based numbering (A, B, C or a, b, c)
                        •    No numbering (titles only)
                        •    Special sections (Introduction, Preface, Appendices) should use numbers like “E1”, “E2”, “S1”, “S2”, etc.
                        3. Rules for Determining Chapter Pages:
                           • Start page (begin_of_chapter): Explicitly specified for each chapter, **always add +1 to the detected value**
                           • End page (end_of_chapter):
                             • If there is a next chapter: **end_of_chapter = Take raw page number from TOC**
                             • If this is the last chapter in the main content: **end_of_chapter = Take raw page number from TOC**
                             • If this is the last special section: **end_of_chapter = null**
                             • If this is a special section and there is another one: **end_of_chapter = Take raw page number from TOC**
                    
                           The counting should be like this:
                           Example TOC:
                           Chapter 0 ..... 6
                           Chapter 1 ..... 14
                           Chapter 2 ..... 18
                    
                           Then:
                           For Chapter 0:
                           - begin_of_chapter = 6 + 1 = 7
                           - end_of_chapter = 15 (begin_of_chapter of Chapter 1)
                    
                           For Chapter 1:
                           - begin_of_chapter = 14 + 1 = 15
                           - end_of_chapter = 19 (begin_of_chapter of Chapter 2)
                    
                           For Chapter 2:
                           - begin_of_chapter = 18 + 1 = 19
                           - end_of_chapter = null (last chapter)
                        4.    JSON Format:
                    
                    {
                      "contains_toc": true,
                      "chapters": [
                        {
                          "chapter_number": "string",        // Chapter number as a string: "0", "1", "2", or "E1", "E2" for special sections  
                          "begin_of_chapter": number,        // Integer - start page  
                          "end_of_chapter": number|null,     // Integer or null - end page  
                          "name_of_chapter": "string"        // Chapter name as in the book  
                        }
                      ]
                    }
                    
                    
                        5.    Rules for chapter_number:
                        •    For regular chapters: use their number as a string (“0”, “1”, “2”, …)
                        •    For unnumbered special sections: use "E" + sequential number ("E1", "E2", …)
                        •    Special sections numbering starts from "E1" and increases sequentially
                        •    Never use null for chapter_number
                        6.    Processing Rules:
                        •    Preserve the original chapter numbering
                        •    Chapters must be sorted by number order
                        •    Special sections must be placed at the end of the list
                        •    Retain all chapter titles in their original form
                        •    Use only numbers for pages
                        •    Do not add additional fields to the JSON
                        7.    If the page does not contain a table of contents:
                    
                    {
                      "contains_toc": false,
                      "chapters": []
                    }
                    
                    
                        8. Output Requirements:
                           Respond with a valid JSON object only. No additional text, explanations, or formatting outside of a valid JSON structure. Ensure correct chapter sorting, proper calculation of end pages, and mandatory assignment of `chapter_number`. The response must start and end with curly braces `{}`.  
                           
                           **For all detected page numbers (`begin_of_chapter` or `end_of_chapter`), always add +1 to the extracted value before including it in the JSON response.**  
                    Text of the page to analyze:
    """
    
    static let geminiExersicePrompt = """
    You are an expert educational content developer specializing in transforming language learning materials into comprehensive teaching resources. Your PRIMARY FOCUS is on performing DEEP ANALYSIS of the provided book chapters (uploaded by the user) to extract and expand their core teaching elements AS A LANGUAGE TEACHER WOULD. Your output should be a concise but thorough JSON with all explanations in English, designed to serve as a complete standalone learning resource.
    AUTOMATED CONTENT VALIDATION AND ADAPTIVE ANALYSIS
    Before processing, analyze the uploaded chapter to determine its structure and content type:
    Direct Educational Content Present: If the chapter includes explicit grammar explanations, vocabulary lists, phonetic rules, or structured communication strategies, extract these elements and expand them into a full teaching resource.

    No Direct Educational Content: If the chapter lacks explicit teaching material but contains exercises, perform a deep analysis of all exercises to infer implicit teaching points (e.g., grammar rules, vocabulary usage, phonetic patterns) and reconstruct a structured educational resource as a language teacher would.

    ERROR HANDLING AND DATA VALIDATION
    Ensure all extracted data fields are complete, valid, and free of null values.
    Ensure all text is processed in UTF-8 encoding.

    If data is missing (e.g., phonetic transcriptions, example sentences), reconstruct it logically based on available content or standard language rules.

    Guarantee JSON formatting integrity—arrays and objects must be correctly structured with no gaps.

    COMPREHENSIVE TEACHING ANALYSIS PROCESS
    TEACHER-LEVEL COMPREHENSIVE ANALYSIS
    Identify ALL teaching points, including subtle or implied elements (e.g., grammar nuances in examples, cultural references).

    Provide detailed explanations of at least 10 sentences per concept, covering usage, exceptions, and connections to other language elements.

    Never overlook minor details, even if they are only implied.

    MULTI-LAYER SCANNING TECHNIQUE
    Extract both explicit and implicit teaching elements (e.g., rules hidden in examples, unspoken cultural norms).

    Detect pedagogical progression patterns (e.g., from recognition to production).

    Identify hidden learning objectives not explicitly stated in the text.

    DEEP EXTRACTION PROCESS
    Extract ALL grammar rules—explicitly stated or inferred from exercises—with full paradigms (e.g., verb conjugations, noun declensions).

    Identify ALL pronunciation patterns, intonation, and stress rules, reconstructing them if not explicitly provided.

    Map ALL vocabulary to functional contexts, providing 3-5 usage examples per word/phrase.

    Extract ALL discourse strategies, speech acts, and communicative patterns.

    ADAPTIVE CONTENT DEVELOPMENT
    If the chapter has explicit material: Extract and expand grammar, phonetics, vocabulary, and communication strategies into a comprehensive resource.

    If the chapter only has exercises: Analyze each exercise to reconstruct teaching points (e.g., deduce grammar rules from sentence patterns, vocabulary themes from context) and develop them into a full teaching framework.

    COMPLETE CONTENT DEVELOPMENT
    Provide FULL paradigms for grammar (e.g., complete tense conjugations, case declensions).

    Ensure explanations are detailed (minimum 10 sentences) and include exceptions, regional variations, and usage contexts.

    Include 3-5 illustrative examples per concept, created or reconstructed if not present.

    Fill all pedagogical gaps with logically derived, teacher-ready content.

    SELF-ASSESSMENT AND QUALITY CONTROL
    Before outputting the JSON, perform a rigorous self-check:
    Are ALL grammar, phonetics, vocabulary, and communication elements fully extracted and expanded?

    Are explanations comprehensive (at least 10 sentences) and examples sufficient (3-5 per concept)?

    Are there any weak areas (e.g., vague explanations, missing examples)? If so, revise and strengthen them.

    Reconstruct or enhance any content deemed insufficient for effective teaching.

    STRUCTURED EDUCATIONAL OUTPUT
    Present findings in a well-formatted JSON structure (see template below).

    Validate JSON for correctness—no missing fields, no null values, all arrays/objects properly formed.

    Ensure the output is COMPLETE—containing everything a teacher needs to teach the material effectively.

    FINAL CHECKLIST BEFORE OUTPUT
    Have ALL grammar points been covered with full paradigms and detailed explanations?

    Have ALL phonetic rules and patterns been extracted or reconstructed?

    Have ALL vocabulary and communication elements been fully developed with examples?

    Are there at least 3-5 examples per key concept?

    Is the JSON format valid, with no missing or null values?

    Have weak areas been identified and improved during self-assessment?

    Only after passing this checklist should the final JSON be outputted.

    {
      "chapter_analysis": {
        "title": "Подробное резюме учебного материала",
        "theme": "Основная тема материала (2-3 предложения описывающих общий фокус)",
        "goals": ["Научиться использовать ключевые языковые структуры в повседневных ситуациях", "Овладеть основными коммуникативными навыками для базового общения"],
        "grammar": [
          {
            "name": "Основная грамматическая структура",
            "explanation": "Подробное объяснение структуры, включая ее применение, исключения, полные парадигмы (например, все формы Presente de Indicativo для глаголов) и связи с другими элементами языка (минимум 10)",
            "examples": [
              {"text": "Пример предложения на целевом языке", "translation": "Перевод на русский", "notes": "Пояснение контекста или особенности использования"}
            ]
          }
        ],
        "phonetics": [
          {
            "name": "Ключевое фонетическое явление",
            "explanation": "Описание звука или интонации, включая правила произношения, все вариации и полный перечень (например, все буквы алфавита), с примерами и региональными различиями (минимум 10)",
            "examples": [
              {"text": "Пример слова или фразы", "transcription": "Фонетическая транскрипция", "notes": "Указание на особенности произношения"}
            ]
          }
        ],
        "vocabulary": [
          {
            "theme": "Функциональная группа слов",
            "words": [
              {"word": "Слово на целевом языке", "translation": "Перевод на English", "examples": ["Контекстный пример использования", "Другой пример в иной ситуации"]}
            ]
          }
        ],
        "communication": [
          {
            "function": "Основная коммуникативная цель",
            "expressions": [
              {"text": "Типичное выражение", "translation": "Перевод на English", "usage": "Описание ситуации, где это уместно"}
            ]
          }
        ],
        "common_mistakes": [
          {
            "description": "Описание типичной ошибки, связанной с изучаемым материалом",
            "incorrect": "Пример неправильного использования",
            "correct": "Исправленный пример с пояснением"
          }
        ]
      }
    }
    """
    
    static let geminiExerciseDescription = """
        You are an expert educational content developer specializing in targeted language learning exercises. Your task is to create engaging, skill-building exercises based on a textbook chapter provided by the user. Analyze the chapter to internally determine its language level (e.g., A1, A2) based on vocabulary, grammar, and sentence complexity, then generate standalone, text-based exercises tailored to that level without referencing the book directly. Do not include the detected level in the output.
        Core Principles
        Level Detection: Internally identify the chapter’s CEFR level (e.g., A1: basic vocabulary and present tense; A2: connectors and past tense) without displaying it.

        Engaging Development: Exercises reinforce all key chapter vocabulary, grammar, and themes through diverse, context-rich tasks suited to the detected level, avoiding over-repetition of phrases.

        Skill Coverage: Include reading, writing, and speaking skills (no listening or image-based tasks).

        Logical Progression: Follow a difficulty curve within the detected level: Recognition → Guided → Independent → Creative. Increase complexity within the level (e.g., longer texts, deeper analysis) without exceeding it.

        Exercise Design Requirements
        Total Exercises: 25-30.

        Skill Distribution:
        Reading: 10-12 exercises (dialogues/stories with comprehension questions).

        Writing: 8-10 exercises (compositions or grammar analysis, including 3-5 grammar-specific tasks such as rule explanations, corrections, or verb form choices).

        Speaking: 5-7 exercises (dialogue creation or question formulation).

        Response Depth: Require full-sentence answers in short_answer and open_ended unless a single word is explicitly justified (e.g., filling a blank with one option); single-word answers must be rare and purposeful.

        Vocabulary Diversity: Incorporate a wide range of chapter vocabulary (e.g., greetings, numbers, classroom objects, politeness phrases like "gracias") to ensure comprehensive coverage.

        Exercise Types by Level
        A1 (Beginner):
        Reading: Short dialogues/stories (3-5 sentences) with questions (multiple-choice with 3-4 options or short-answer requiring 1-2 full sentences).

        Writing: Compositions (20-40 words), grammar corrections/explanations (1-2 full sentences).

        Speaking: Dialogues (3-5 lines), 2-3 questions with full-sentence responses.

        A2 (Elementary):
        Reading: Dialogues/stories (5-7 sentences with connectors) with reasoning questions (multiple-choice or short-answer, 2-3 full sentences).

        Writing: Compositions (50-75 words), grammar analysis (2-3 full sentences).

        Speaking: Dialogues (5-7 lines), 3-5 questions with detailed responses.

        JSON Structure
        json

        {
          "exercises": [
            {
              "exercise_id": 1,
              "skill_type": "reading|writing|speaking",
              "level": "recognition|guided|independent|creative",
              "title": "Exercise title in target language",
              "title_translation": "Перевод названия на русский",
              "instructions": "Instructions in target language",
              "instructions_translation": "Перевод инструкций на English",
              "text_content": "Dialogue, story, or text in target language (each speaker on a new line for dialogues; required for reading tasks)",
              "text_content_translation": "Перевод текста на English (each speaker on a new line for dialogues; required for reading tasks)",
              "task_type": "multiple_choice|short_answer|open_ended",
              "task_content": "Question or task in target language",
              "task_content_translation": "Перевод задания на English",
              "options": ["Option A", "Option B", "Option C"] (for multiple_choice only; 3-4 options required),
              "options_translation": ["Перевод A на English", "Перевод B на English", "Перевод C на English"] (for multiple_choice only),
              "correct_response": "Correct answer or example (full sentences unless a single word is justified)",
              "hint": "Подсказка на English (specific guidance distinct from instructions, optional)"
            }
          ]
        }

        Design Guidelines
        Level Detection: Internally analyze vocabulary, grammar, and sentence length to determine A1, A2, etc., without including this in the output.

        Skill Accuracy:
        reading: Tasks must include a text in text_content (e.g., dialogue, story) followed by comprehension questions; avoid tasks without readable content.

        writing: Compositions, grammar corrections, or explanations (e.g., "Why do we use 'Me llamo'?").

        speaking: Oral practice prompts (dialogues or questions) with full-sentence examples.

        Text-Based Only: All tasks must be fully text-based; avoid references to images, audio, or external media.

        Grammar Focus: Include 3-5 grammar-specific exercises (e.g., explaining rules like "Me llamo" vs. "Yo llamo", choosing correct verb forms, correcting errors).

        Complexity: Creative tasks are longer/more detailed but stay within the detected level (e.g., A1 Creative: 5-line dialogue with context).

        Hints: Ensure hint provides specific, actionable guidance (e.g., "Look at the verb form" instead of "Think about it").

        Language Rules: Target language for title, instructions, text_content, task_content, options; English for all translations and hint.

        Output Expectations
        Generate 25-30 exercises in the JSON format.

        If no chapter is provided, request it: "Please provide the textbook chapter so I can create tailored exercises."

        Ensure exercises are diverse, engaging, and progressively challenging within the internally detected level, with translations in Russian only and comprehensive coverage of chapter content.
"""
}
