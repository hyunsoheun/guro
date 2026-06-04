# 구로 반나절 PRD — Claude Code 입력용 핸드오프 팩

> 본문: `prd-구로반나절-20260602.md`
> 사용처: frd-writer 입력 / Claude Code 시스템 프롬프트 / 개발 착수 참조
> 성격: 정밀 데이터 카탈로그. 처음부터 끝까지 읽는 용도가 아니다. 필요한 섹션을 부분 참조한다.

---

## 1. 잠긴 결정 (Locked Decisions)

- 프레임워크: Next.js 14 App Router + Tailwind CSS
- DB + 인증 + 스토리지: Supabase (PostgreSQL, Supabase Auth, Supabase Storage)
- 카카오 로그인: Kakao OAuth 2.0 (Supabase Auth Provider 중계)
- 지도: 카카오맵 JavaScript API (Intersection Observer 지연 로딩)
- 이미지 압축: browser-image-compression (클라이언트 사이드, 2MB 상한)
- 호스팅: Vercel 무료 플랜 (GitHub 자동 배포)
- 분석: Google Analytics 4
- 개발 방식: Claude Code / Cursor 바이브코딩
- 코스 수: 1개 통합 코스
- 스탬프 완료 조건: 핵심 3곳 모두 사진 인증 + 서버 측 DB Function 검증
- 핵심 3곳: 넷마블 게임 박물관 / 남구로 시장 / 중국 베이커리(호떡집)
- 사은품 방식: 완료 화면 캡처 (닉네임 + 완료 일시 표시)
- 필수 기능: F-001 ~ F-015 (11개)
- 선택 기능: F-030 ~ F-033 (4개)
- 후순위 기능: F-040 ~ F-042 (3개)

---

## 2. 기능 카탈로그 (전체 ID)

### 2.1 코스 소개 + 지도 (랜딩페이지 / )

| ID | 기능명 | 분류 | 화면 | 왜 필요 | Empty | Loading | Error |
|---|---|---|---|---|---|---|---|
| F-001 | 코스 헤더 (제목·대표 이미지·핵심 카피) | 필수 | / | 첫 인상 형성 | 해당 없음 | 스켈레톤 | 기본 텍스트 폴백 |
| F-002 | 장소별 카드 (사진·이름·소요시간·예산·설명) | 필수 | / | 가치 제안 본체. 없으면 블로그와 동일 | 해당 없음 | 카드 스켈레톤 | "정보를 불러오지 못했어요" |
| F-003 | 총 예산·시간 요약 배지 (상단 고정) | 필수 | / | 의사결정 핵심 정보. 첫눈에 보여야 함 | 해당 없음 | — | "—" 표시 |
| F-004 | 카카오맵 임베드 (Intersection Observer 지연 로딩) | 필수 | / | 이동 동선 시각화. 없으면 실행 불가 | 해당 없음 | "지도 불러오는 중..." | "지도를 불러오지 못했어요. 새로고침 해주세요" |
| F-005 | 스탬프 도전 CTA 버튼 (플로팅 고정) | 필수 | / | 스탬프 진입 유일 경로 | 해당 없음 | — | — |

### 2.2 스탬프 시스템 (/stamp, /stamp/[place-id], /stamp/complete)

| ID | 기능명 | 분류 | 화면 | 왜 필요 | Empty | Loading | Error |
|---|---|---|---|---|---|---|---|
| F-010 | 카카오 로그인 (Kakao OAuth 2.0) | 필수 | /auth/callback | 스탬프 기록 전제 조건 | — | "카카오 로그인 중..." | "로그인 실패. 다시 시도해 주세요" |
| F-011 | 스탬프 체크리스트 (핵심 3곳 + 전체 장소 목록) | 필수 | /stamp | 무엇을 인증할지 표시 | "아직 방문한 곳이 없어요. 코스를 시작해 보세요!" | 스켈레톤 | "스탬프 정보를 불러오지 못했어요" |
| F-012 | 사진 업로드 인증 (장소별, 2MB 상한, 클라이언트 자동 압축) | 필수 | /stamp/[place-id] | 방문 증명 수단 | — | "사진 업로드 중..." | "업로드 실패. 파일 형식을 확인해 주세요 (JPG·PNG·WEBP)" |
| F-013 | 진행 상황 표시 ("2/3 완료") | 필수 | /stamp | 이탈 방지. 얼마나 왔는지 보여줌 | "0/3 완료" | — | — |
| F-014 | 스탬프 완료 화면 (카카오 닉네임·완료 일시 + 사은품 캡처 안내) | 필수 | /stamp/complete | 도전 완료 경험. 어뷰징 억제용 닉네임 표시 | — | — | — |
| F-015 | 완료 여부 서버 측 검증 (DB Function: is_stamp_complete) | 필수 | /stamp/complete | 클라이언트 조작 방지 필수 | — | "완료 확인 중..." | "완료 확인 실패. 다시 시도해 주세요" |

### 2.3 선택·후순위 기능

| ID | 기능명 | 분류 | 비고 |
|---|---|---|---|
| F-030 | 비추천 대상 안내 | 선택 | 향신료 약한 분, 어린아이 동반 가족 (PPT 원안) |
| F-031 | SNS 공유 버튼 (카카오톡 공유·링크 복사) | 선택 | 랜딩 하단 배치 |
| F-032 | 이전 인증 기록 보존 (재방문 시 이어하기) | 선택 | Supabase 세션 유지로 구현 |
| F-033 | 사은품 지급 처리 상태 체크 | 선택 | Supabase 대시보드 뷰로 대체 가능 |
| F-040 | 방문 후기 섹션 | 후순위 | stamps 데이터 50건 이상 쌓인 후 검토 |
| F-041 | 스탬프 완료 공유 카드 ("구로 반나절 완주!") | 후순위 | SNS 바이럴용 이미지 카드 |
| F-042 | 방문자 통계 대시보드 | 후순위 | GA4로 대체. 별도 화면 불필요 |

---

## 3. 데이터 스키마 (SQL)

### 3.1 테이블 정의

```sql
-- 장소 테이블 (코스 내 모든 장소)
CREATE TABLE places (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name        text NOT NULL,
  description text,
  address     text,
  is_required boolean DEFAULT false,  -- 핵심 3곳 여부
  order_num   int NOT NULL,           -- 코스 내 표시 순서
  created_at  timestamptz DEFAULT now()
);

-- 사용자 프로필 (Supabase Auth 연동)
CREATE TABLE user_profiles (
  id         uuid REFERENCES auth.users PRIMARY KEY,
  kakao_id   text UNIQUE,
  nickname   text,
  created_at timestamptz DEFAULT now()
);

-- 스탬프 테이블 (장소당 1회 인증, UNIQUE 제약)
CREATE TABLE stamps (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid REFERENCES user_profiles(id) NOT NULL,
  place_id   uuid REFERENCES places(id) NOT NULL,
  photo_url  text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, place_id)
);
```

### 3.2 완료 판정 DB Function (서버 측 검증 — F-015)

```sql
-- 핵심 3곳(is_required=true) 모두 인증했는지 서버에서 확인
-- 클라이언트 조작 방지를 위해 반드시 이 함수로만 완료 판정
CREATE OR REPLACE FUNCTION is_stamp_complete(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT COUNT(*) = (
    SELECT COUNT(*) FROM places WHERE is_required = true
  )
  FROM stamps s
  JOIN places p ON s.place_id = p.id
  WHERE s.user_id = p_user_id
    AND p.is_required = true;
$$;
```

### 3.3 RLS 정책 + Storage Policy

```sql
-- stamps 테이블: 본인 데이터만 INSERT·SELECT 가능
ALTER TABLE stamps ENABLE ROW LEVEL SECURITY;

CREATE POLICY stamps_insert ON stamps
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY stamps_select_own ON stamps
  FOR SELECT
  USING (auth.uid() = user_id);

-- user_profiles: 본인 프로필만 읽기·쓰기 가능
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_all ON user_profiles
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- places: 전체 공개 읽기 (로그인 불필요)
ALTER TABLE places ENABLE ROW LEVEL SECURITY;

CREATE POLICY places_read_all ON places
  FOR SELECT USING (true);
```

```
-- Supabase Storage bucket policy (콘솔에서 설정)
-- bucket name: stamp-photos
-- allowed MIME types: image/jpeg, image/png, image/webp, image/heic
-- max file size: 2MB (프론트엔드 압축 후 업로드)
-- public: false (URL 직접 접근 차단)
```

### 3.4 인덱스

```sql
CREATE INDEX idx_stamps_user_id   ON stamps(user_id);
CREATE INDEX idx_stamps_place_id  ON stamps(place_id);
CREATE INDEX idx_places_required  ON places(is_required);
CREATE INDEX idx_places_order     ON places(order_num);
```

### 3.5 초기 데이터 시딩 (places 테이블)

```sql
INSERT INTO places (name, description, address, is_required, order_num) VALUES
  ('깔깔 거리 식당',      '점심 식사. 인당 1.5만원, 소요 1시간',          '서울 구로구 디지털로',  false, 1),
  ('넷마블 게임 박물관',   '게임 체험 + 레트로 오락실. 인당 2만원, 1.5시간', '서울 구로구 디지털로',  true,  2),
  ('커피 브레이크',        '인당 7천원, 30분',                             '서울 구로구 디지털로',  false, 3),
  ('G밸리 산업 박물관',   '구로공단 역사 + VR. 무료, 30분',               '서울 구로구 디지털로',  false, 4),
  ('남구로 시장',          '중국 식재료·간판·분위기. 간식 구매 1만원',       '서울 구로구 남구로',    true,  5),
  ('린궁즈멘관',           '중국 본토 음식. 인당 1만원, 40분',             '서울 구로구 남구로',    false, 6),
  ('중국 베이커리',        '중국 호떡·호빵. 사은품 수령 장소',              '서울 구로구 남구로',    true,  7);
```

---

## 4. AI 호출 프롬프트

해당 없음. 구로 반나절 v1은 LLM API 직접 호출 기능을 포함하지 않는다.

---

## 5. 비기능 요구사항 (NFR)

| 항목 | 요구사항 | 측정 방법 |
|---|---|---|
| 초기 로드 속도 | 3초 이내 (모바일 LTE 기준) | Vercel Analytics / Lighthouse Mobile |
| 이미지 업로드 상한 | 장당 2MB 이하 (browser-image-compression으로 클라이언트 압축) | 라이브러리 maxSizeMB: 2 옵션 |
| 지도 로딩 방식 | Intersection Observer로 뷰포트 진입 시 API 호출 | Chrome DevTools Network 탭 |
| 보안 — 스탬프 쓰기 | 로그인된 본인만 INSERT 가능 (Supabase RLS) | Supabase 정책 테스트 |
| 보안 — 업로드 파일 | image/* MIME 타입만 허용 | Storage bucket policy + input accept 속성 |
| 보안 — 완료 판정 | 서버 측 DB Function 단독 처리 | is_stamp_complete() 함수 |
| 개인정보 수집 범위 | 카카오 닉네임만 수집 (전화번호·이메일 미수집) | Supabase Auth Kakao Provider 스코프 설정 |
| 호환성 | 모바일 크롬·사파리 최신 2버전 | 실기기 테스트 (iOS Safari, Android Chrome) |
| 카카오맵 API 한도 | 월 30만 건 이내 (무료 플랜) | 카카오 개발자 콘솔 모니터링 |

---

## 6. 화면 ID 카탈로그

| 화면 ID | 화면명 | URL | 분류 | 인증 필요 | 관련 기능 |
|---|---|---|---|---|---|
| S-001 | 랜딩페이지 | / | Core | 불필요 | F-001~F-005 |
| S-002 | 카카오 로그인 콜백 | /auth/callback | Auth | 불필요 | F-010 |
| S-003 | 스탬프 체크리스트 | /stamp | Core | 필요 | F-011, F-013 |
| S-004 | 장소별 사진 업로드 | /stamp/[place-id] | Core | 필요 | F-012 |
| S-005 | 스탬프 완료 | /stamp/complete | Core | 필요 | F-014, F-015 |

각 화면의 상태(Empty / Loading / Error / Disabled) 전체 명세는 FRD에서 정의.

---

## 7. 외부 통합 상세

| 서비스 | 용도 | 인증 방식 | 비용 | 한도 | 대체 방안 |
|---|---|---|---|---|---|
| Kakao OAuth 2.0 | 카카오 로그인 | Supabase Auth Provider | 무료 | 없음 | 이메일 로그인 |
| 카카오맵 JavaScript API | 지도 임베드 | JavaScript 앱 키 (환경 변수) | 무료 | 월 30만 건 | 구글맵 Static API |
| Supabase | DB·스토리지·인증 통합 | Anon Key + Service Role Key | 무료 (500MB DB, 1GB Storage) | 500MB / 1GB | PlanetScale + Cloudinary |
| Vercel | 호스팅, GitHub 자동 배포 | GitHub OAuth | 무료 | 100GB 대역폭/월 | Netlify |
| Google Analytics 4 | UV·체류·이벤트 측정 | 측정 ID (Script 태그) | 무료 | 없음 | Plausible.io |

---

## 8. 미해결 / FRD에서 결정할 항목

- **스탬프 완료 판정 트리거 시점**: 마지막 사진 업로드 직후 자동 확인인지, 별도 "완료 확인" 버튼 클릭 후인지 → FRD S-004·S-005 흐름 설계에서 결정
- **카카오 로그인 팝업 차단 대응 UX**: 팝업 차단 감지 방법과 안내 문구·허용 방법 링크 설계 → FRD S-002 Error 상태 설계에서 결정
- **/stamp 진입 시 미로그인 처리**: 로그인 없이 /stamp 직접 접근 시 리다이렉트 vs 인라인 안내 → FRD S-003 인증 게이트 설계에서 결정
- **장소 데이터 시딩 방식**: Supabase 콘솔 직접 입력 vs 시드 스크립트 → TRD 또는 Claude Code 프롬프트에서 처리

---

## 9. FRD 작성 시 핵심 변수

| 변수 | 값 |
|---|---|
| 화면 목록 | S-001 ~ S-005 (총 5개) |
| 필수 기능 목록 | F-001 ~ F-015 (총 11개) |
| Supabase 스키마 SQL | 본 파일 §3.1 그대로 사용 |
| 완료 판정 DB Function | is_stamp_complete(user_id) — 본 파일 §3.2 |
| RLS 정책 SQL | 본 파일 §3.3 그대로 사용 |
| NFR 수치 | 본 파일 §5 그대로 사용 |
| 화면별 URL | 본 파일 §6 참조 |
| 초기 장소 데이터 | 본 파일 §3.5 INSERT SQL |

---

## 10. Claude Code 호환성 체크

- [x] 기능 ID 명확히 부여 (F-001 ~ F-042)
- [x] 각 기능의 Empty·Loading·Error 상태 정의
- [x] 화면 URL 명시 (S-001 ~ S-005)
- [x] DB 스키마 SQL 포함 (CREATE TABLE, 직접 실행 가능)
- [x] RLS 정책 SQL 포함
- [x] 서버 검증 DB Function SQL 포함 (is_stamp_complete)
- [x] 초기 데이터 시드 SQL 포함 (places 테이블)
- [x] 외부 API 키 환경 변수 목록 명시 (§7)
- [ ] AI 호출 프롬프트: 해당 없음

---

## 11. 다음 스킬 호출

**다음 단계**: frd-writer
**호출 방법**: `"FRD 작성해줘"`
**frd-writer에 제공할 입력 (두 파일 모두)**:
1. `prd-구로반나절-20260602.md` (본문 — 사람용 보고서)
2. `prd-구로반나절-20260602-handoff.md` (이 파일 — 정밀 데이터 카탈로그)
