-- =========================================================================
-- 구로 반나절 프로젝트 Supabase 데이터베이스 스키마 및 초기화 SQL
-- =========================================================================

-- 1. 기존 테이블/함수 삭제 (재실행 가능하게 처리)
DROP FUNCTION IF EXISTS is_stamp_complete(uuid);
DROP TABLE IF EXISTS stamps;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS places;

-- 2. 장소 테이블 생성
CREATE TABLE places (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name        text NOT NULL,
  description text,
  address     text,
  is_required boolean DEFAULT false,  -- 핵심 3곳 여부 (넷마블 게임 박물관, 남구로 시장, 중국 베이커리)
  order_num   int NOT NULL,           -- 코스 내 표시 순서
  created_at  timestamptz DEFAULT now()
);

-- 3. 사용자 프로필 테이블 생성 (Supabase Auth 연동)
CREATE TABLE user_profiles (
  id         uuid REFERENCES auth.users PRIMARY KEY,
  kakao_id   text UNIQUE,
  nickname   text,
  created_at timestamptz DEFAULT now()
);

-- 4. 스탬프 테이블 생성 (사용자별 장소당 1회 인증 제한)
CREATE TABLE stamps (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid REFERENCES user_profiles(id) NOT NULL,
  place_id   uuid REFERENCES places(id) NOT NULL,
  photo_url  text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, place_id)
);

-- 5. 완료 판정 DB Function 생성
-- 핵심 3곳(is_required=true) 모두 인증했는지 서버 측에서 확인하는 함수
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

-- 6. Row Level Security (RLS) 활성화
ALTER TABLE stamps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;

-- 7. RLS 보안 정책 정의

-- stamps 테이블 정책
CREATE POLICY stamps_insert ON stamps
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY stamps_select_own ON stamps
  FOR SELECT
  USING (auth.uid() = user_id);

-- user_profiles 테이블 정책
CREATE POLICY profiles_all ON user_profiles
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- places 테이블 정책 (전체 조회 가능, 쓰기 불가)
CREATE POLICY places_read_all ON places
  FOR SELECT USING (true);

-- 8. 성능 최적화용 인덱스 추가
CREATE INDEX idx_stamps_user_id   ON stamps(user_id);
CREATE INDEX idx_stamps_place_id  ON stamps(place_id);
CREATE INDEX idx_places_required  ON places(is_required);
CREATE INDEX idx_places_order     ON places(order_num);

-- 9. 초기 장소 데이터 시딩
INSERT INTO places (name, description, address, is_required, order_num) VALUES
  ('깔깔 거리 식당',      '점심 식사. 인당 1.5만원, 소요 1시간',          '서울 구로구 디지털로',  false, 1),
  ('넷마블 게임 박물관',   '게임 체험 + 레트로 오락실. 인당 2만원, 1.5시간', '서울 구로구 디지털로',  true,  2),
  ('커피 브레이크',        '인당 7천원, 30분',                             '서울 구로구 디지털로',  false, 3),
  ('G밸리 산업 박물관',   '구로공단 역사 + VR. 무료, 30분',               '서울 구로구 디지털로',  false, 4),
  ('남구로 시장',          '중국 식재료·간판·분위기. 간식 구매 1만원',       '서울 구로구 남구로',    true,  5),
  ('린궁즈멘관',           '중국 본토 음식. 인당 1만원, 40분',             '서울 구로구 남구로',    false, 6),
  ('중국 베이커리',        '중국 호떡·호빵. 사은품 수령 장소',              '서울 구로구 남구로',    true,  7);
