package com.gmail.sacchin13.spring_boot_sample.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.gmail.sacchin13.spring_boot_sample.entity.WazaInfo;

@Repository
public interface WazaInfoRepository extends JpaRepository<WazaInfo, Integer> {
}