## 🏷️ 프로젝트 개요

<div align="center"><img src="https://github.com/user-attachments/assets/7b29a4f9-bd2a-421b-9620-23d8fcff2035" width="200px" alt="로고"></div>

- **주제 및 이름 :** 소중한 사람들과의 추억을 사진과 채팅으로 기록하는 추억 지도, **위맵 (WeMap)**
- **기간** : 2024. 04 - 2024. 05 (기획 제외 약 8주)
- **역할** : 기획 및 개발 (1인 프로젝트)
- **개발 도구 및 기술 스택** : `Xcode`, `Swift`, `UIKit`, `Firebase`
- **목적** : 특정 장소에 대한 추억은 보통 사진이나 영상 같은 미디어로 남기곤 하지만, 이런 방식만으로는 그 순간의 경험을 온전히 담아내기 어렵습니다. 이 프로젝트는 단순한 미디어 저장이나 리뷰 작성을 넘어서 사용자들이 서로 소통하고 교류할 수 있는 커뮤니티 중심의 상호작용에 초점을 맞췄습니다. 단순히 이미지를 기록하는 데 그치지 않고 장소에서의 생생한 경험을 더 풍부하게 담고 자유롭게 공유할 수 있도록 기획되었습니다.
<br>

## 📖 프로젝트 내용

### 1️⃣ 친구 요청 기능 및 친구 목록

<table>
  <thead>
    <tr>
      <th width="50%">친구 요청 화면</th>
      <th width="50%">친구 목록</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/def6fa39-24d7-4494-a5d3-b35438c43472" width="200px" alt="친구 요청 화면"></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/7283f0b1-ac93-4949-9206-42dbd2b36e00" width="200px" alt="친구 목록"></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>친구 요청 화면에서 친구를 <b>검색</b>해서 <b>친구 요청</b>을 할 수 있습니다.</li>
          <ul>
            <li>친구 요청 중일 때 <b>친구 요청 취소</b>를 할 수 있습니다.</li>
            <li>이미 친구일 경우, 해당 친구가 이미 나에게 요청을 보냈을 경우 친구 요청을 할 수 없습니다.</li>
        </ul>
        </ul>
      </td>
      <td>
        <ul>
          <li>친구 목록에 친구가 가나다순으로 정렬되어 보입니다.</li>
          <li>이름으로 친구를 <b>검색</b>할 수 있습니다.</li>
          <li>친구를 <b>즐겨찾기</b>할 수 있습니다.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

### 2️⃣ 알림 목록 및 프로필 편집

<table>
  <thead>
    <tr>
      <th width="50%">마이 페이지, 알림 화면</th>
      <th width="50%">프로필 편집 화면</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/fb8e20b5-dd1e-47d4-8117-3f514a062f2c" width="200px" alt="마이 페이지, 알림 화면"></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/083d175b-0ea1-443f-9fe1-adaa87a58b46" width="200px" alt="프로필 편집 화면"></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>마이 페이지에서 참여 중인 최근 추억 앨범을 볼 수 있습니다.</li>
          <li>마이 페이지 화면을 통해 <b>알림</b> 화면으로 들어갈 수 있습니다.</li>
          <ul>
            <li><b>친구 요청</b>이나 <b>앨범 초대</b> 알림을 수락 및 거절할 수 있습니다.</li>
        </ul>
        </ul>
      </td>
      <td>
        <ul>
          <li>설정을 통해 프로필 편집 화면으로 들어갈 수 있습니다.</li>
          <li><b>프로필 사진과 이름, 프로필 메시지</b>를 <b>변경</b>할 수 있습니다.</li>
          <ul>
            <li>변경 사항이 있는 경우에만 완료 버튼이 활성화됩니다.</li>
        </ul>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

### 3️⃣ 지도 및 주소 상세 보기

<table>
  <thead>
    <tr>
      <th width="50%">홈 화면 (지도)</th>
      <th width="50%">주소 상세 화면</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/6d73e9bc-bf08-4374-bd2b-57819d4682d7" width="200px" alt="홈 화면 (지도)"></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/f9ab1b47-906b-473d-b8e7-27489cf97007" width="200px" alt="주소 상세 화면"></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li><b>지도 인터페이스</b>(나침반 버튼, 현위치 버튼, 줌 버튼)를 포함한 네이버 지도를 표시합니다.</li>
          <ul>
            <li><b>네이버 지도 API</b>를 사용하였습니다.</li>
          </ul>
          <li>Bottom Sheet를 포함합니다.</li>
          <ul>
            <li>‘Floating Panel’ 라이브러리를 사용하였습니다.</li>
          </ul>
        </ul>
      </td>
      <td>
        <ul>
          <li>지도를 터치하면 터치한 장소의 주소를 불러옵니다.</li>
          <ul>
            <li>빨간색 마커를 추가하고, 해당 위치가 가운데로 오도록 카메라를 이동합니다.</li>
            <li>네이버 지도의 <b>geocoding API</b>와 <b>reverse geocoding API</b>를 사용하였습니다.</li>
          </ul>
          <li>주소 상세 화면에서 최근 추억 앨범을 보거나 생성할 수 있습니다.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

### 4️⃣ 추억 앨범 생성 및 상세 보기

<table>
  <thead>
    <tr>
      <th width="50%">추억 앨범 생성 화면</th>
      <th width="50%">추억 앨범 상세 화면</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/eff83764-ca81-4b00-a8a4-e5a2d62970af" width="200px" alt="추억 앨범 생성 화면"></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/5d0b54c1-9113-4b85-a8ae-239f9def8ee3" width="200px" alt="추억 앨범 상세 화면"></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li><b>친구 선택</b> 화면에서 함께한 친구를 선택하거나 취소할 수 있습니다.</li>
          <li>친구를 <b>검색</b>할 수 있습니다.</li>
          <li>앨범 생성 화면에서 <b>선택된 친구를 취소</b>할 수 있습니다.</li>
          <ul>
            <li>친구 선택 화면에서도 반영됩니다.</li>
          </ul>
          <li><b>날짜</b>와 <b>추억 앨범 이름</b>을 지정할 수 있습니다.</li>
          <li>앨범 생성 완료 시 해당 장소에 파란색 마커가 생깁니다.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>참여하고 있는 <b>멤버</b>를 볼 수 있습니다.</li>
          <ul>
            <li>자신의 프로필이 가장 앞에 나타나고, 아직 초대를 수락하지 않은 멤버는 로딩 아이콘이 뜹니다.</li>
          </ul>
          <li>사진을 추가할 수 있고, 멤버들과 채팅이 가능한 화면으로 이동할 수 있습니다.</li>
          <ul>
            <li>몇 개의 최근 사진과 마지막 채팅을 <b>미리보기</b>로 볼 수 있습니다.</li>
          </ul>
          <li>설정 화면으로 갈 수 있습니다.</li>
          <ul>
            <li><b>설정 화면</b>에서는 현재 앨범에서 나가거나 앨범을 <b>삭제</b>할 수 있습니다.</li>
          </ul>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

### 5️⃣ 사진 전체보기 및 채팅

<table>
  <thead>
    <tr>
      <th width="50%">사진 목록 화면</th>
      <th width="50%">채팅 화면</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/bec2df24-4111-42b2-b33e-24185990c22a" width="200px" alt="사진 목록 화면"></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/2acc0d68-4485-4d49-8ee4-26efa5ab93fd" width="200px" alt="채팅 화면"></td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>앨범에서 사진을 <b>여러 장</b> 선택해 추가할 수 있습니다.</li>
          <ul>
            <li>사진은 타임스탬프와 함께 저장이 됩니다.</li>
          </ul>
        </ul>
      </td>
      <td>
        <ul>
          <li>텍스트 뷰에 텍스트가 있을 때만 전송 버튼이 활성화됩니다.</li>
          <li>상대방의 채팅에서, 같은 사람이 여러 번 보냈을 경우 가장 위에만 프로필 사진 및 이름을 보입니다.</li>
          <li>채팅의 <b>시간과 날짜</b>가 함께 표시됩니다.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>
